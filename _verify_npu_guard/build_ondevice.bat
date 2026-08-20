@echo off
setlocal
cd /d "%~dp0"
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
if errorlevel 1 ( echo VCVARS_FAILED & exit /b 2 )
set "OSS=C:\Users\mrbla\oss\openvino"
set "BIN=%OSS%\bin\intel64\RelWithDebInfo"
echo === compiling on-device test (links build openvino.lib) ===
cl /nologo /std:c++17 /EHsc /MD /DNDEBUG /W3 ^
  /I"%OSS%\src\core\include" /I"%OSS%\src\inference\include" ^
  ondevice_npu.cpp /Fe:ondevice_npu.exe ^
  /link "%BIN%\openvino.lib"
if errorlevel 1 ( echo COMPILE_FAILED & exit /b 3 )
echo build OK
endlocal
