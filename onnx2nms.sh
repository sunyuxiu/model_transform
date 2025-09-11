# #!/bin/bash
# # 使用方法: ./onnx2nms.sh <base_dir> <numcls>
# # 示例:   ./onnx2nms.sh /home/scy/train/exps/nofar/hbb_fire-smoke_cls2/hbb_fire-smoke_cls2_v0.5.0 6

# BASE_DIR="$1"
# NUMCLS="$2"
# KEEP_TOPK=300

# POSTPROCESS_SCRIPT="/home/scy/train/LorenzoDeploy/cv_detection/nvidia/yoloe2e/v2/python/yolov8/yolov8_add_postprocess.py"
# NMS_SCRIPT="/home/scy/train/LorenzoDeploy/cv_detection/nvidia/yoloe2e/v2/python/yolov8/yolov8_add_nms.py"

# if [ -z "$BASE_DIR" ] || [ -z "$NUMCLS" ]; then
#     echo "Usage: $0 <base_dir> <numcls>"
#     exit 1
# fi

# echo "Start ONNX -> _1.onnx & _1_nms.onnx in $BASE_DIR ..."
# echo "Number of classes = $NUMCLS"

# for dir in "$BASE_DIR"/*/; do
#     dir="${dir%/}"
#     weights_dir="$dir/weights"
#     short_model_name=$(basename "$dir" | cut -d'_' -f1)

#     for onnx_file in "$weights_dir/"*.onnx; do
#         [ -f "$onnx_file" ] || continue

#         # 提取 batch 信息（如果文件名里有 _bXX）
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
#   ./onnx2nms.sh <base_dir> <numcls>

BASE_DIR="$1"
NUMCLS="$2"

KEEP_TOPK=300

POSTPROCESS_SCRIPT="/home/scy/train/LorenzoDeploy/cv_detection/nvidia/yoloe2e/v2/python/yolov8/yolov8_add_postprocess.py"
NMS_SCRIPT="/home/scy/train/LorenzoDeploy/cv_detection/nvidia/yoloe2e/v2/python/yolov8/yolov8_add_nms.py"


if [ -z "$BASE_DIR" ] || [ -z "$NUMCLS" ]; then
    echo "Usage: $0 <base_dir> <numcls>"
    exit 1
fi

echo "Start ONNX -> _1.onnx & _1_nms.onnx in $BASE_DIR ..."
echo "Number of classes = $NUMCLS"

# 遍历 BASE_DIR 下所有子目录（递归）
find "$BASE_DIR" -type f -name "*.onnx" | while read -r onnx_file; do
    model_name=$(basename "$onnx_file" .onnx)
    dir_name=$(dirname "$onnx_file")

    post_onnx="$dir_name/${model_name}_1.onnx"
    nms_onnx="$dir_name/${model_name}_1_nms.onnx"

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

