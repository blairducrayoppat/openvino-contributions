@echo off
rem Stage 2: npu_compiler developer build (RelWithDebInfo) against the stage-1 OpenVINO dev package.
rem ENABLE_DEVELOPER_BUILD=true via preset -> IE_NPU_IR_PRINTING_FILTER and friends become available.
rem Throttled by launcher: BelowNormal priority class, -j 4.
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
set OPENVINO_HOME=C:\Users\mrbla\oss\openvino
cd /d C:\Users\mrbla\oss\npu_compiler

echo CONFIGURE_START %date% %time% > C:\Users\mrbla\oss\npu_build_status.txt
cmake --preset developer-build-relwithdebinfo . > C:\Users\mrbla\oss\npu_configure.log 2>&1
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
