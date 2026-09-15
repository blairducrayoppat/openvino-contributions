@echo off
set BIN=C:\Users\<user>\oss\openvino\bin\intel64\RelWithDebInfo
set PATH=%BIN%;%PATH%
set MODEL=C:\Users\<user>\models\qwen3-0.6b\openvino-int4-npu\openvino_model.xml
cd /d C:\Users\<user>\oss\repro266
set OV_NPU_LOG_LEVEL=LOG_NONE
C:\Users\<user>\oss\repro266\harness\repro34651.exe "%MODEL%"
echo EXITCODE=%ERRORLEVEL%
