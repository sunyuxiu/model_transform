# import os
# import subprocess

# # 模型目录
# model_dir = "/home/scy/temp/obb_device_cls14_v0.2.0"

# # 遍历目录下所有 .onnx 文件
# for file_name in os.listdir(model_dir):
#     if file_name.endswith(".onnx"):
#         file_path = os.path.join(model_dir, file_name)
#         print(f"Processing {file_path} ...")
#         # 调用 v8trans.py 转换
#         subprocess.run(["python3", "/home/scy/tools/script_tools/v8_trans.py", file_path])


# python obb2trans.py aaa,aaa下有pt2onnx生成的onnx模型路径
import os
import subprocess
import sys

# 检查命令行参数
if len(sys.argv) < 2:
    print(f"Usage: python3 {sys.argv[0]} <model_dir>")
    sys.exit(1)

# 从命令行获取模型目录
model_dir = sys.argv[1]

# 遍历目录下所有 .onnx 文件
for file_name in os.listdir(model_dir):
    if file_name.endswith(".onnx"):
        file_path = os.path.join(model_dir, file_name)
        print(f"Processing {file_path} ...")
        # 调用 v8_trans.py 转换
        subprocess.run(["python3", "/home/scy/tools/script_tools/v8_trans.py", file_path], check=True)
