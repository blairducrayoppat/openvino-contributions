@echo off
rem Stage 2 resume: disable LLVM DIA SDK support (needs ATL headers not present in Build Tools),
rem then continue the developer build. Existing objects are reused by ninja.
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
set OPENVINO_HOME=C:\Users\mrbla\oss\openvino
cd /d C:\Users\mrbla\oss\npu_compiler

echo RECONFIG_START %date% %time% > C:\Users\mrbla\oss\npu_build_status.txt
cmake -DLLVM_ENABLE_DIA_SDK:BOOL=OFF build-x86_64\RelWithDebInfo >> C:\Users\mrbla\oss\npu_configure.log 2>&1
if errorlevel 1 (
    echo CONFIGURE_FAILED %date% %time% >> C:\Users\mrbla\oss\npu_build_status.txt
    exit /b 1
)
echo CONFIGURE_OK %date% %time% >> C:\Users\mrbla\oss\npu_build_status.txt

cmake --build build-x86_64\RelWithDebInfo -- -j 4 > C:\Users\mrbla\oss\npu_build.log 2>&1
if errorlevel 1 (
    echo BUILD_FAILED %date% %time% >> C:\Users\mrbla\oss\npu_build_status.txt
    exit /b 1
)
echo BUILD_OK %date% %time% >> C:\Users\mrbla\oss\npu_build_status.txt
