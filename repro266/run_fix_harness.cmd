@echo off
rem Re-run the NPUW static-LLM harness AFTER the unroll_group_quantize location fix.
rem Captures to fix_run_*.log so the pre-fix clean_*.log evidence is preserved for comparison.
set BIN=C:\Users\mrbla\oss\openvino\bin\intel64\RelWithDebInfo
set PATH=%BIN%;%PATH%
set MODEL=C:\Users\mrbla\models\qwen3-0.6b\openvino-int4-npu\openvino_model.xml
cd /d C:\Users\mrbla\oss\repro266
set OV_NPU_LOG_LEVEL=LOG_INFO
C:\Users\mrbla\oss\repro266\harness\repro266.exe "%MODEL%" > C:\Users\mrbla\oss\repro266\fix_run_out.log 2> C:\Users\mrbla\oss\repro266\fix_run_err.log
echo EXITCODE=%ERRORLEVEL%
