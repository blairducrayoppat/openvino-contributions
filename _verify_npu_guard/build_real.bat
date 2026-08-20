@echo off
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
if errorlevel 1 ( echo VCVARS_FAILED & exit /b 2 )
echo === building ov_npu_unit_tests (real gtest target) ===
cmake --build "C:\Users\mrbla\oss\openvino\build-x86_64\RelWithDebInfo" --target ov_npu_unit_tests
echo BUILD_EXIT=%errorlevel%
