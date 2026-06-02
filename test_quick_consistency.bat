@echo off
setlocal enabledelayedexpansion

echo ===================================================
echo   EasyWave CPU vs GPU Quick Consistency Test
echo ===================================================
echo.

if not exist "build\easywave-cuda.exe" (
    echo [ERROR] build\easywave-cuda.exe not found!
    echo Please build the CUDA project first using build-cuda.bat.
    pause
    exit /b 1
)
if not exist "build\easywave-sycl.exe" (
    echo [ERROR] build\easywave-sycl.exe not found!
    echo Please build the SYCL project first using build-sycl-no-make.bat.
    pause
    exit /b 1
)

set "GRID=%CD%\easyWave-master-data\data\grids\g08r4Indonesia.grd"
set "SOURCE=%CD%\easyWave-master-data\data\faults\BengkuluSept2007.flt"
set "POI=%CD%\easyWave-master-data\data\pois\poiIndonesia.poi"
set SIM_TIME=10

echo Creating output directories...
if not exist "test-cpu-out" mkdir "test-cpu-out"
if not exist "test-gpu-out" mkdir "test-gpu-out"

echo Cleaning old files...
del /Q test-cpu-out\eWave.* 2>nul
del /Q test-gpu-out\eWave.* 2>nul

echo.
echo [1/3] Running CPU Simulation (SYCL)...
cd test-cpu-out
..\build\easywave-sycl.exe -grid "%GRID%" -source "%SOURCE%" -poi "%POI%" -time %SIM_TIME% >nul 2>&1
cd ..

echo [2/3] Running GPU Simulation (CUDA)...
cd test-gpu-out
..\build\easywave-cuda.exe -gpu -grid "%GRID%" -source "%SOURCE%" -poi "%POI%" -time %SIM_TIME% >nul 2>&1
cd ..

echo.
echo [3/3] Automatic Analysis...
echo Comparing 2D sshmax grids...
compare.exe "test-cpu-out\eWave.2D.sshmax" "test-gpu-out\eWave.2D.sshmax" 1e-4
set RESULT=%errorlevel%

echo.
echo Comparing POI ssh time-series...
compare_poi.exe "test-cpu-out\eWave.poi.ssh" "test-gpu-out\eWave.poi.ssh" 1e-4
set POI_RESULT=%errorlevel%

if %POI_RESULT% neq 0 set RESULT=1

if %RESULT% neq 0 (
    echo.
    echo ===================================================
    echo  [FAILED] CPU and GPU outputs do not match!
    echo ===================================================
) else (
    echo.
    echo ===================================================
    echo  [SUCCESS] CPU and GPU outputs match!
    echo ===================================================
)

echo.
pause
exit /b %RESULT%
