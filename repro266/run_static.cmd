@echo off
set BIN=C:\Users\mrbla\oss\openvino\bin\intel64\RelWithDebInfo
set PATH=%BIN%;%PATH%
set MODEL=C:\Users\mrbla\models\qwen3-0.6b\openvino-int4-npu\openvino_model.xml
cd /d C:\Users\mrbla\oss\repro266

set IE_NPU_CRASH_REPRODUCER_FILE=C:\Users\mrbla\oss\repro266\reproducer.mlir
set IE_NPU_GEN_LOCAL_REPRODUCER=1
set OV_NPU_LOG_LEVEL=LOG_INFO

echo RUN_START %date% %time%
"%BIN%\compile_tool.exe" -m "%MODEL%" -d NPU -c C:\Users\mrbla\oss\repro266\config.txt -shape "input_ids[1,128],attention_mask[1,128],position_ids[1,128],beam_idx[1]" -o C:\Users\mrbla\oss\repro266\out.blob
echo EXITCODE=%ERRORLEVEL%
echo RUN_END %date% %time%
