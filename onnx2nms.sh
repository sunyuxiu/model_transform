# #!/bin/bash
# # 使用方法: ./onnx2nms.sh /home/scy/train/exps/nofar/hbb_fire-smoke_cls2/hbb_fire-smoke_cls2_v0.5.0

# BASE_DIR="$1"
# NUMCLS=6
# KEEP_TOPK=300

# POSTPROCESS_SCRIPT="/home/scy/train/LorenzoDeploy/cv_detection/nvidia/yoloe2e/v2/python/yolov8/yolov8_add_postprocess.py"
# NMS_SCRIPT="/home/scy/train/LorenzoDeploy/cv_detection/nvidia/yoloe2e/v2/python/yolov8/yolov8_add_nms.py"

# if [ -z "$BASE_DIR" ]; then
#     echo "Usage: $0 <base_dir>"
#     exit 1
# fi

# echo "Start ONNX -> _1.onnx & _1_nms.onnx in $BASE_DIR ..."

# for dir in "$BASE_DIR"/*/; do
#     dir="${dir%/}"
#     weights_dir="$dir/weights"
#     short_model_name=$(basename "$dir" | cut -d'_' -f1)

#     for onnx_file in "$weights_dir/"*.onnx; do
#         [ -f "$onnx_file" ] || continue

#         # 提取 batch 信息
#         batch=$(basename "$onnx_file" | sed -r "s/.*_b([0-9]+)\.onnx/\1/")

#         # Step 1: Postprocess -> _1.onnx
#         post_onnx="$weights_dir/$(basename "$onnx_file" .onnx)_1.onnx"
#         if [ ! -f "$post_onnx" ]; then
#             echo "🛠 Running postprocess on $onnx_file -> $post_onnx ..."
#             python "$POSTPROCESS_SCRIPT" --inputmodel "$onnx_file" \
#                                          --outputmodel "$post_onnx" \
#                                          --numcls $NUMCLS
#             if [ $? -ne 0 ]; then
#                 echo "❌ Postprocess failed for $onnx_file"
#                 continue
#             fi
#         else
#             echo "Postprocess file $post_onnx exists, skipping."
#         fi

#         # Step 2: NMS -> _1_nms.onnx
#         nms_onnx="$weights_dir/$(basename "$onnx_file" .onnx)_1_nms.onnx"
#         if [ ! -f "$nms_onnx" ]; then
#             echo "🛠 Running NMS on $post_onnx -> $nms_onnx ..."
#             python "$NMS_SCRIPT" --model "$post_onnx" \
#                                  --numcls $NUMCLS \
#                                  --keepTopK $KEEP_TOPK
#             if [ $? -ne 0 ]; then
#                 echo "❌ NMS failed for $post_onnx"
#                 continue
#             fi
#         else
#             echo "NMS file $nms_onnx exists, skipping."
#         fi

#     done

#     echo "-----------------------------------------"
# done

# echo "🎉 All ONNX -> _1.onnx & _1_nms.onnx done!"





#!/bin/bash
# 使用方法:
#   1) ./onnx2nms.sh <base_dir>
#   2) ./onnx2nms.sh <base_dir> <output_dir>

BASE_DIR="$1"
OUTPUT_DIR="$2"

NUMCLS=2
KEEP_TOPK=300

POSTPROCESS_SCRIPT="/home/scy/train/LorenzoDeploy/cv_detection/nvidia/yoloe2e/v2/python/yolov8/yolov8_add_postprocess.py"
NMS_SCRIPT="/home/scy/train/LorenzoDeploy/cv_detection/nvidia/yoloe2e/v2/python/yolov8/yolov8_add_nms.py"
# POSTPROCESS_SCRIPT="/home/scy/train/LorenzoDeploy/cv_detection/nvidia/yoloe2e/v2/python/yolov8/yolov8_obb_add_postprocess.py"
# NMS_SCRIPT="/home/scy/train/LorenzoDeploy/cv_detection/nvidia/yoloe2e/v2/python/yolov8/yolov8_obb_add_nms.py"

if [ -z "$BASE_DIR" ]; then
    echo "Usage: $0 <base_dir> [output_dir]"
    exit 1
fi

if [ -n "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
    echo "ONNX outputs will be saved to: $OUTPUT_DIR"
else
    echo "ONNX outputs will be saved to the same dir as input ONNX files"
fi

echo "Start ONNX -> _1.onnx & _1_nms.onnx in $BASE_DIR ..."

# 遍历 BASE_DIR 下所有子目录（递归）
find "$BASE_DIR" -type f -name "*.onnx" | while read -r onnx_file; do
    model_name=$(basename "$onnx_file" .onnx)

    # 如果指定了输出目录，则放到 OUTPUT_DIR，否则放到 onnx 同级目录
    if [ -n "$OUTPUT_DIR" ]; then
        post_onnx="$OUTPUT_DIR/${model_name}_1.onnx"
        nms_onnx="$OUTPUT_DIR/${model_name}_1_nms.onnx"
    else
        post_onnx="$(dirname "$onnx_file")/${model_name}_1.onnx"
        nms_onnx="$(dirname "$onnx_file")/${model_name}_1_nms.onnx"
    fi

    # Step 1: Postprocess -> _1.onnx
    if [ ! -f "$post_onnx" ]; then
        echo "🛠 Running postprocess on $onnx_file -> $post_onnx ..."
        python "$POSTPROCESS_SCRIPT" --inputmodel "$onnx_file" \
                                     --outputmodel "$post_onnx" \
                                     --numcls $NUMCLS
        if [ $? -ne 0 ]; then
            echo "❌ Postprocess failed for $onnx_file"
            continue
        fi
    else
        echo "Postprocess file $post_onnx exists, skipping."
    fi

    # Step 2: NMS -> _1_nms.onnx
    if [ ! -f "$nms_onnx" ]; then
        echo "🛠 Running NMS on $post_onnx -> $nms_onnx ..."
        python "$NMS_SCRIPT" --model "$post_onnx" \
                             --numcls $NUMCLS \
                             --keepTopK $KEEP_TOPK
        if [ $? -ne 0 ]; then
            echo "❌ NMS failed for $post_onnx"
            continue
        fi
    else
        echo "NMS file $nms_onnx exists, skipping."
    fi

    echo "-----------------------------------------"
done

echo "🎉 All ONNX -> _1.onnx & _1_nms.onnx done!"
