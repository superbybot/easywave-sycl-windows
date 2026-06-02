@echo off
echo Recompiling CUDA...
call .\build-cuda.bat > build_cuda.log 2>&1
if errorlevel 1 (
    echo CUDA Build failed. Check build_cuda.log
    exit /b 1
)

echo Recompiling SYCL...
call .\build-sycl-no-make.bat > build_sycl.log 2>&1
if errorlevel 1 (
    echo SYCL Build failed. Check build_sycl.log
    exit /b 1
)

echo Packaging standalone build...
call .\make-standalone.bat > make_standalone.log 2>&1
if errorlevel 1 (
    echo Packaging failed. Check make_standalone.log
    exit /b 1
)

echo Running CPU simulation (SYCL)...
.\build\easywave-sycl.exe -grid "easyWave-master-data\data\grids\e2r4Asean.grd" -source "easyWave-master-data\data\faults\fault.inp" -time 10 -label eWave_CPU_full > run_cpu.log 2>&1

echo Running GPU simulation (CUDA)...
.\build\easywave-cuda.exe -grid "easyWave-master-data\data\grids\e2r4Asean.grd" -source "easyWave-master-data\data\faults\fault.inp" -time 10 -label eWave_GPU_full -gpu > run_gpu.log 2>&1

echo Comparing...
.\compare.exe eWave_CPU_full.2D.sshmax eWave_GPU_full.2D.sshmax 1e-4
