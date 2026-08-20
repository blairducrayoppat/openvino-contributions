@echo off
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
cd /d C:\Users\mrbla\oss\openvino.genai
echo GENAI_CONFIGURE_START %date% %time% > C:\Users\mrbla\oss\ov_genai_build_status.txt
cmake -S . -B build-gpu -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo -DOpenVINODeveloperPackage_DIR=C:/Users/mrbla/oss/openvino/build-x86_64/RelWithDebInfo -DENABLE_PYTHON=OFF > C:\Users\mrbla\oss\ov_genai_build.log 2>&1
set RC=%errorlevel%
if %RC% neq 0 goto cfgfail
echo GENAI_CONFIGURE_OK %date% %time% >> C:\Users\mrbla\oss\ov_genai_build_status.txt
cmake --build build-gpu -- -j 8 >> C:\Users\mrbla\oss\ov_genai_build.log 2>&1
set RC=%errorlevel%
if %RC% neq 0 goto buildfail
echo GENAI_BUILD_OK %date% %time% >> C:\Users\mrbla\oss\ov_genai_build_status.txt
goto done
:cfgfail
echo GENAI_CONFIGURE_FAILED rc=%RC% %date% %time% >> C:\Users\mrbla\oss\ov_genai_build_status.txt
exit /b %RC%
:buildfail
echo GENAI_BUILD_FAILED rc=%RC% %date% %time% >> C:\Users\mrbla\oss\ov_genai_build_status.txt
exit /b %RC%
:done
