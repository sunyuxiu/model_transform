#!/bin/bash

# 假设 trtexec 和这个脚本在同一目录下
TRTEXEC="./trtexec"
BASE_DIR="/home/scy/train/YOLO-Pruning-RKNN/runs/detect_0802_hbb_action_cls9_v0.7.1"

for dir in "$BASE_DIR"/*/; do
    # 提取目录路径（去掉末尾斜杠）
    dir="${dir%/}"
    weights_dir="$dir/weights"

    # 查找符合模式的 ONNX 文件
    onnx_file=$(find "$weights_dir" -maxdepth 1 -name 'best_1_nms_fp16_nms.onnx' | head -n 1)

    if [ -f "$onnx_file" ]; then
        engine_file="$weights_dir/best.bin"

        echo "Processing: $onnx_file"
        "$TRTEXEC" \
            --onnx="$onnx_file" \
            --saveEngine="$engine_file" \
            --workspace=9000 \
            --verbose
        echo "Saved: $engine_file"
        echo "-------------------------------------"
        sleep 3
    else
        echo "Skipping $dir: ONNX file not found."
    fi
done

echo "All bin file is finished."

