@echo off
setlocal
cd /d "%~dp0"
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
if errorlevel 1 ( echo VCVARS_FAILED & exit /b 2 )
set "SDK=C:\Users\mrbla\.venv-ov-upstream-smoke\Lib\site-packages\openvino"
set "PLUG=C:\Users\mrbla\oss\openvino\src\plugins\intel_npu\src\plugin"
echo === compiling MUTANT (cl) ===
cl /nologo /std:c++17 /EHsc /MD /W3 /I"%PLUG%\include" /I"%SDK%\include" model_validation_mut.cpp verify_main.cpp /Fe:verify_mut.exe /link "%SDK%\libs\openvino.lib"
if errorlevel 1 ( echo COMPILE_FAILED & exit /b 3 )
echo === running MUTANT (expect FAILURES = test caught the mutation) ===
set "PATH=%SDK%\libs;%PATH%"
verify_mut.exe
echo MUTANT_EXITCODE=%errorlevel%
endlocal
