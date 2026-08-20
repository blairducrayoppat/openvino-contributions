@echo off
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
cd /d C:\Users\mrbla\oss\openvino
echo OVPY_CONFIGURE_START %date% %time% > C:\Users\mrbla\oss\ov_python_build_status.txt
cmake -S . -B build-x86_64\RelWithDebInfo -DENABLE_PYTHON=ON -DPython3_EXECUTABLE=C:/Users/mrbla/oss/ovpy-venv/Scripts/python.exe -DPython3_INCLUDE_DIR=C:/Users/mrbla/AppData/Local/Programs/Python/Python311/include -DPython3_LIBRARY=C:/Users/mrbla/AppData/Local/Programs/Python/Python311/libs/python311.lib > C:\Users\mrbla\oss\ov_python_build.log 2>&1
set RC=%errorlevel%
if %RC% neq 0 goto cfgfail
echo OVPY_CONFIGURE_OK %date% %time% >> C:\Users\mrbla\oss\ov_python_build_status.txt
cmake --build build-x86_64\RelWithDebInfo --target pyopenvino openvino_c -- -j 8 >> C:\Users\mrbla\oss\ov_python_build.log 2>&1
set RC=%errorlevel%
if %RC% neq 0 goto buildfail
echo OVPY_BUILD_OK %date% %time% >> C:\Users\mrbla\oss\ov_python_build_status.txt
goto done
:cfgfail
echo OVPY_CONFIGURE_FAILED rc=%RC% %date% %time% >> C:\Users\mrbla\oss\ov_python_build_status.txt
exit /b %RC%
:buildfail
echo OVPY_BUILD_FAILED rc=%RC% %date% %time% >> C:\Users\mrbla\oss\ov_python_build_status.txt
exit /b %RC%
:done
