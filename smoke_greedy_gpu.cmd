@echo off
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
cmake --build "C:\Users\<user>\oss\openvino.genai\build-gpu" --target greedy_causal_lm -- -j 8
if errorlevel 1 ( echo REBUILD_FAILED & exit /b 1 )
set PATH=C:\Users\<user>\oss\openvino\bin\intel64\RelWithDebInfo;C:\Users\<user>\oss\openvino.genai\build-gpu\openvino_genai;%PATH%
echo === greedy_causal_lm on device=GPU (from-source plugin) ===
"C:\Users\<user>\oss\openvino.genai\build-gpu\bin\greedy_causal_lm.exe" "C:\Users\<user>\models\qwen3-0.6b\openvino-int4-gpu" "The capital of France is"
echo.
echo === exit=%errorlevel% ===
