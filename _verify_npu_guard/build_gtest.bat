@echo off
setlocal
cd /d "%~dp0"
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
if errorlevel 1 ( echo VCVARS_FAILED & exit /b 2 )
set "SDK=C:\Users\mrbla\.venv-ov-upstream-smoke\Lib\site-packages\openvino"
set "FORK=C:\Users\mrbla\oss\openvino\src\plugins\intel_npu"
set "GT=C:\Users\mrbla\oss\openvino\thirdparty\gtest\gtest"
set "BLIB=C:\Users\mrbla\oss\openvino\build-x86_64\RelWithDebInfo\lib"
echo === compiling REAL gtest binary (committed test file + my own gtest main) ===
cl /nologo /std:c++17 /EHsc /MD /DNDEBUG /W3 ^
  /I"%FORK%\src\plugin\include" /I"%SDK%\include" ^
  /I"%GT%\googletest\include" /I"%GT%\googlemock\include" ^
  "%FORK%\tests\unit\npu\unbounded_dynamic_shape.cpp" ^
  "%FORK%\src\plugin\src\model_validation.cpp" ^
  gtest_driver.cpp ^
  /Fe:real_gtest.exe ^
  /link "%BLIB%\gmock.lib" "%BLIB%\gtest.lib" "%SDK%\libs\openvino.lib"
if errorlevel 1 ( echo COMPILE_FAILED & exit /b 3 )
echo === build OK ===
endlocal
