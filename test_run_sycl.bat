@echo off
REM Set up Intel oneAPI environment
call "C:\Program Files (x86)\Intel\oneAPI\setvars.bat" --force

REM Run on default device (Integrated GPU)
set ONEAPI_DEVICE_SELECTOR=

echo Creating outputs-sycl directory...
if not exist "outputs-sycl" mkdir "outputs-sycl"

echo Deleting previous output files...
del /Q outputs-sycl\eWave.* 2>nul

echo.
echo Running simulation in SYCL MODE...
echo ========================================
echo Start time: %date% %time%
echo ========================================
echo.

set "GRID=%CD%\easyWave-master-data\data\grids\GEBCO_Nothern_Phil_15s.grd"
set "SOURCE=%CD%\easyWave-master-data\data\faults\Phil_Trench_06.flt"
set "POI=%CD%\easyWave-master-data\data\pois\Aurora.poi"

cd outputs-sycl
..\build\easywave-sycl.exe -gpu -verbose -grid "%GRID%" -source "%SOURCE%" -poi "%POI%" -time 480 -step 1 -progress 1
cd ..

echo.
echo ========================================
echo Simulation complete!
echo End time: %date% %time%
echo ========================================
echo.

if exist "outputs-sycl\eWave.2D.sshmax" (
    echo SUCCESS! Main output file created: eWave.2D.sshmax
) else (
    echo WARNING: Main output file missing
)
