@echo off
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
cd /d C:\Users\mrbla\oss\openvino.genai
echo GENAIPY_CONFIGURE_START %date% %time% > C:\Users\mrbla\oss\ov_genaipy_build_status.txt
cmake -S . -B build-gpu -DENABLE_PYTHON=ON -DPython3_EXECUTABLE=C:/Users/mrbla/oss/ovpy-venv/Scripts/python.exe -DPython3_INCLUDE_DIR=C:/Users/mrbla/AppData/Local/Programs/Python/Python311/include -DPython3_LIBRARY=C:/Users/mrbla/AppData/Local/Programs/Python/Python311/libs/python311.lib -DOpenVINODeveloperPackage_DIR=C:/Users/mrbla/oss/openvino/build-x86_64/RelWithDebInfo > C:\Users\mrbla\oss\ov_genaipy_build.log 2>&1
set RC=%errorlevel%
if %RC% neq 0 goto cfgfail
echo GENAIPY_CONFIGURE_OK %date% %time% >> C:\Users\mrbla\oss\ov_genaipy_build_status.txt
cmake --build build-gpu --target py_openvino_genai -- -j 8 >> C:\Users\mrbla\oss\ov_genaipy_build.log 2>&1
set RC=%errorlevel%
if %RC% neq 0 goto buildfail
echo GENAIPY_BUILD_OK %date% %time% >> C:\Users\mrbla\oss\ov_genaipy_build_status.txt
goto done
:cfgfail
echo GENAIPY_CONFIGURE_FAILED rc=%RC% %date% %time% >> C:\Users\mrbla\oss\ov_genaipy_build_status.txt
exit /b %RC%
:buildfail
echo GENAIPY_BUILD_FAILED rc=%RC% %date% %time% >> C:\Users\mrbla\oss\ov_genaipy_build_status.txt
exit /b %RC%
:done
