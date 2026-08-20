@echo off
rem Incremental rebuild after the unroll_group_quantize location fix.
rem Only the changed object + dependent links recompile (minutes, not hours).
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
set OPENVINO_HOME=C:\Users\mrbla\oss\openvino
cd /d C:\Users\mrbla\oss\npu_compiler
cmake --build build-x86_64\RelWithDebInfo -- -j 4 > C:\Users\mrbla\oss\fix_build.log 2>&1
exit /b %ERRORLEVEL%
