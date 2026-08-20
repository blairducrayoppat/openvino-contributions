@echo off
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
cd /d C:\Users\mrbla\oss\openvino.genai
echo GENAI_SAMPLES_START %date% %time% > C:\Users\mrbla\oss\ov_genai_build_status.txt
cmake --build build-gpu --target greedy_causal_lm benchmark_genai -- -j 8 > C:\Users\mrbla\oss\ov_genai_build.log 2>&1
set RC=%errorlevel%
if %RC% neq 0 goto fail
echo GENAI_SAMPLES_OK %date% %time% >> C:\Users\mrbla\oss\ov_genai_build_status.txt
goto done
:fail
echo GENAI_SAMPLES_FAILED rc=%RC% %date% %time% >> C:\Users\mrbla\oss\ov_genai_build_status.txt
exit /b %RC%
:done
