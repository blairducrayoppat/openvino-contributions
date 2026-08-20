@echo off
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
cd /d "C:\Users\mrbla\oss\openvino\build-x86_64\RelWithDebInfo"
set "LOG=C:\Users\mrbla\oss\_verify_npu_guard\build_log.txt"
echo BUILD_START %DATE% %TIME% > "%LOG%"
echo --- reconfigure (pick up new model_validation.cpp via globs) --- >> "%LOG%"
cmake . >> "%LOG%" 2>&1
echo --- build (capped -j 4) --- >> "%LOG%"
cmake --build . --target openvino_intel_npu_plugin ov_npu_unit_tests -j 4 >> "%LOG%" 2>&1
echo BUILD_EXIT=%errorlevel% >> "%LOG%"
echo BUILD_DONE %DATE% %TIME% >> "%LOG%"
