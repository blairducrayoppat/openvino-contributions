@echo off
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
cd /d C:\Users\mrbla\oss\openvino
echo GPU_CONFIGURE_START %date% %time% > C:\Users\mrbla\oss\ov_gpu_build_status.txt
cmake --build build-x86_64\RelWithDebInfo --target openvino_intel_gpu_plugin -- -j 8 > C:\Users\mrbla\oss\ov_gpu_build.log 2>&1
set RC=%errorlevel%
if %RC% neq 0 goto fail
echo GPU_BUILD_OK %date% %time% >> C:\Users\mrbla\oss\ov_gpu_build_status.txt
goto done
:fail
echo GPU_BUILD_FAILED rc=%RC% %date% %time% >> C:\Users\mrbla\oss\ov_gpu_build_status.txt
exit /b %RC%
:done
