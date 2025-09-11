#!/bin/bash
# 使用方法: ./onnx2bin.sh /home/scy/train/exps/nofar/hbb_fire-smoke_cls2/hbb_fire-smoke_cls2_v0.5.0

# BASE_DIR="$1"
# TRTEXEC="./trtexec"
# GPU_ID=2

# if [ -z "$BASE_DIR" ]; then
#     echo "Usage: $0 <base_dir>"
#     exit 1
# fi

# echo "Start ONNX -> TensorRT BIN in $BASE_DIR ..."

# for dir in "$BASE_DIR"/*/; do
#     dir="${dir%/}"
#     weights_dir="$dir/weights"
#     short_model_name=$(basename "$dir" | cut -d'_' -f1)

#     for nms_onnx in "$weights_dir/"*_1_nms.onnx; do
#         [ -f "$nms_onnx" ] || continue

#         # 提取 batch 信息，例如 b32
#         batch=$(basename "$nms_onnx" | sed -r "s/.*_b([0-9]+)_1_nms.onnx/\1/")

#         # 构造 BIN 文件名: model11e2e_b64m_20250802_hbb_fire-smoke_cls2_v0.5.0_b32_fp16.bin
#         base_name=$(basename "$nms_onnx" "_1_nms.onnx")      # 去掉 _1_nms
#         engine_file="${short_model_name}e2e_${base_name#${short_model_name}_}_fp16.bin"
#         engine_path="$weights_dir/$engine_file"

#         if [ ! -f "$engine_path" ]; then
#             echo "🏁 Converting $nms_onnx -> $engine_path ..."
#             "$TRTEXEC" \
#                 --onnx="$nms_onnx" \
#                 --saveEngine="$engine_path" \
#                 --workspace=9000 \
#                 --device=$GPU_ID \
#                 --verbose
#             if [ $? -eq 0 ]; then
#                 echo "✅ Saved engine: $engine_path"
#                 ls -lh "$engine_path"
#             else
#                 echo "❌ FAILED to convert: $nms_onnx"
#             fi
#         else
#             echo "BIN file $engine_path already exists, skipping."
#         fi
#     done

#     echo "-----------------------------------------"
# done

# echo "🎉 ONNX -> BIN done!"




#!/bin/bash
# 使用方法:
#   1) ./onnx2bin.sh <base_dir>
#   2) ./onnx2bin.sh <base_dir> <output_dir>

BASE_DIR="$1"
OUTPUT_DIR="$2"
TRTEXEC="./trtexec"
GPU_ID=2

if [ -z "$BASE_DIR" ]; then
    echo "Usage: $0 <base_dir> [output_dir]"
    exit 1
fi

if [ -n "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
    echo "BIN outputs will be saved to: $OUTPUT_DIR"
else
    echo "BIN outputs will be saved to the same dir as input ONNX files"
fi

echo "Start ONNX -> TensorRT BIN in $BASE_DIR ..."

# 遍历 BASE_DIR 下所有 *_1_nms.onnx 文件
find "$BASE_DIR" -type f -name "*_1_nms.onnx" | while read -r nms_onnx; do
    dir=$(dirname "$nms_onnx")

    # 去掉 _1_nms 后缀
    base_name=$(basename "$nms_onnx" "_1_nms.onnx")

    # 提取模型开头，例如 model8
    model_head=$(echo "$base_name" | cut -d'_' -f1)

    # 拼接 engine 文件名
    rest_name=${base_name#${model_head}_}   # 去掉开头 model8_
    engine_file="${model_head}e2e_${rest_name}_fp16.bin"

    # 输出路径
    if [ -n "$OUTPUT_DIR" ]; then
        engine_path="$OUTPUT_DIR/$engine_file"
    else
        engine_path="$dir/$engine_file"
    fi

    if [ ! -f "$engine_path" ]; then
        echo "🏁 Converting $nms_onnx -> $engine_path ..."
        "$TRTEXEC" \
            --onnx="$nms_onnx" \
            --saveEngine="$engine_path" \
            --workspace=9000 \
            --device=$GPU_ID \
            --verbose
        if [ $? -eq 0 ]; then
            echo "✅ Saved engine: $engine_path"
            ls -lh "$engine_path"
        else
            echo "❌ FAILED to convert: $nms_onnx"
        fi
    else
        echo "BIN file $engine_path already exists, skipping."
    fi

    echo "-----------------------------------------"
done

echo "🎉 ONNX -> BIN done!"
