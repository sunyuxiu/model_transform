# !/bin/bash
# # 使用方法: ./pt2onnx.sh /home/scy/train/exps/nofar/hbb_fire-smoke_cls2/hbb_fire-smoke_cls2_v0.5.0

# BASE_DIR="$1"
# BATCH_SIZES=(16 32 64)

# if [ -z "$BASE_DIR" ]; then
#     echo "Usage: $0 <base_dir>"
#     exit 1
# fi

# echo "Start exporting PT to ONNX in $BASE_DIR ..."

# for dir in "$BASE_DIR"/*/; do
#     dir="${dir%/}"
#     weights_dir="$dir/weights"
#     model_name=$(basename "$dir")

#     if [ ! -f "$weights_dir/best.pt" ]; then
#         echo "⚠️ best.pt not found in $weights_dir, skipping..."
#         continue
#     fi

#     for batch in "${BATCH_SIZES[@]}"; do
#         target_onnx="$weights_dir/${model_name}_b${batch}.onnx"

#         if [ -f "$target_onnx" ]; then
#             echo "ONNX for batch $batch already exists, skipping."
#             continue
#         fi

#         echo "📦 Exporting $weights_dir/best.pt with batch $batch..."
#         yolo export model="$weights_dir/best.pt" format=onnx batch=$batch

#         onnx_file="$weights_dir/best.onnx"
#         if [ -f "$onnx_file" ]; then
#             mv "$onnx_file" "$target_onnx"
#             echo "✅ Renamed ONNX to $target_onnx"
#         else
#             echo "❌ Failed to export ONNX for batch $batch"
#         fi
#     done

#     echo "-----------------------------------------"
# done

# echo "🎉 All PT -> ONNX done!"


#!/bin/bash
# 用法:
#   ./pt2onnx.sh <base_dir> [output_dir]

BASE_DIR="$1"
OUTPUT_DIR="$2"
BATCH_SIZES=(16 32 64)

if [ -z "$BASE_DIR" ]; then
    echo "Usage: $0 <base_dir> [output_dir]"
    exit 1
fi

if [ -n "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
else
    OUTPUT_DIR="$BASE_DIR"
fi

# 遍历所有子目录中的 *.pt 文件
pt_files=$(find "$BASE_DIR" -type f -name "*.pt")

for pt_file in $pt_files; do
    model_name=$(basename "$pt_file" .pt)
    model_dir=$(dirname "$pt_file")

    for batch in "${BATCH_SIZES[@]}"; do
        target_onnx="$OUTPUT_DIR/${model_name}_b${batch}.onnx"
        if [ -f "$target_onnx" ]; then
            echo "✅ $target_onnx exists, skip."
            continue
        fi

        echo "📦 Exporting $pt_file batch $batch ..."
        
        # 直接导出，不用临时目录
        if yolo export model="$pt_file" format=onnx batch=$batch; then
            # YOLO 会默认保存到和 pt 同目录下，名字就是 ${model_name}.onnx
            src="$model_dir/${model_name}.onnx"
            if [ -f "$src" ]; then
                mv "$src" "$target_onnx"
                echo "✅ Saved $target_onnx"
            else
                echo "❌ Export ran but ONNX not found at $src"
            fi
        else
            echo "❌ Failed $pt_file batch $batch (export error)"
        fi
    done
done

echo "🎉 All PT -> ONNX done!"





