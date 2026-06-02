@echo off
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
cl /EHsc compare.cpp
compare.exe eWave_CPU_nc.2D.sshmax eWave_GPU_nc.2D.sshmax
