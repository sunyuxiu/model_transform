#!/bin/bash

TRTEXEC="./trtexec"
GPU_ID=0
BASE_DIR="/home/scy/train/exps/nofar/hbb_fire-smoke_cls2/hbb_fire-smoke_cls2_v0.5.0"

echo "Using GPU ID: $GPU_ID"
echo "Start processing..."

for dir in "$BASE_DIR"/*/; do
    dir="${dir%/}"
    weights_dir="$dir/weights"

    echo "Processing directory: $dir"

    if [ -d "$weights_dir" ]; then
        echo "Listing files in $weights_dir:"
        ls -l "$weights_dir"

        for onnx_file in "$weights_dir"/*_1_nms.onnx; do
            [ -f "$onnx_file" ] || continue
            echo "Found ONNX file: $onnx_file"

            filename=$(basename "$onnx_file")
            engine_file="${filename%_1_nms.onnx}_fp16.bin"
            engine_path="$weights_dir/$engine_file"

            if [ -f "$engine_path" ]; then
                echo "BIN file already exists, skipping: $engine_path"
            else
                echo "Converting ONNX to BIN..."
                "$TRTEXEC" \
                    --onnx="$onnx_file" \
                    --saveEngine="$engine_path" \
                    --workspace=9000 \
                    --device=$GPU_ID \
                    --verbose

                if [ $? -eq 0 ]; then
                    echo "✅ Saved engine: $engine_path"
                    ls -lh "$engine_path"
                else
                    echo "❌ FAILED to convert: $onnx_file"
                fi
            fi
        done

    else
        echo "⚠️ Weights directory not found in: $dir"
    fi

    echo "-------------------------------------"
done

echo "🎉 All bin file conversions finished."
