@echo off
set BIN=C:\Users\mrbla\oss\openvino\bin\intel64\RelWithDebInfo
set PATH=%BIN%;%PATH%
set MODEL=C:\Users\mrbla\models\qwen3-0.6b\openvino-int4-npu\openvino_model.xml
cd /d C:\Users\mrbla\oss\repro266

set IE_NPU_CRASH_REPRODUCER_FILE=C:\Users\mrbla\oss\repro266\reproducer_clean.mlir
set IE_NPU_GEN_LOCAL_REPRODUCER=1
set OV_NPU_LOG_LEVEL=LOG_INFO

C:\Users\mrbla\oss\repro266\harness\repro266.exe "%MODEL%"
echo EXITCODE=%ERRORLEVEL%
