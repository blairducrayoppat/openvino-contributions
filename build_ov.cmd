@echo off
rem Stage 1: OpenVINO @ e4e180d (npu_compiler pinned commit), RelWithDebInfo developer flavor.
rem Throttled by launcher: BelowNormal priority class (inherited by ninja/cl), -j 4.
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
cd /d C:\Users\mrbla\oss\openvino

echo CONFIGURE_START %date% %time% > C:\Users\mrbla\oss\ov_build_status.txt
cmake -G Ninja ^
    -DCMAKE_BUILD_TYPE=RelWithDebInfo ^
    -DENABLE_INTEL_NPU=ON ^
    -DENABLE_PLUGINS_XML=ON ^
    -DENABLE_INTEL_NPU_COMPILER=OFF ^
    -DENABLE_DEBUG_CAPS=ON ^
    -DENABLE_TESTS=ON ^
    -DENABLE_FUNCTIONAL_TESTS=ON ^
    -DENABLE_PYTHON=OFF ^
    -B build-x86_64\RelWithDebInfo > C:\Users\mrbla\oss\ov_configure.log 2>&1
if errorlevel 1 (
    echo CONFIGURE_FAILED %date% %time% >> C:\Users\mrbla\oss\ov_build_status.txt
    exit /b 1
)
echo CONFIGURE_OK %date% %time% >> C:\Users\mrbla\oss\ov_build_status.txt

cmake --build build-x86_64\RelWithDebInfo --target ov_dev_targets openvino_intel_npu_plugin compile_tool -- -j 4 > C:\Users\mrbla\oss\ov_build.log 2>&1
if errorlevel 1 (
    echo BUILD_FAILED %date% %time% >> C:\Users\mrbla\oss\ov_build_status.txt
    exit /b 1
)
echo BUILD_OK %date% %time% >> C:\Users\mrbla\oss\ov_build_status.txt
