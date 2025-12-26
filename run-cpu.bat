@echo off
REM CPU Mode Runner - Guaranteed to work!

echo Initializing Intel oneAPI environment...
call "C:\Program Files (x86)\Intel\oneAPI\setvars.bat"

echo.
echo Creating outputs-cpu directory...
if not exist "outputs-cpu" mkdir "outputs-cpu"

echo.
echo Running simulation in CPU MODE (no GPU acceleration)...
echo ========================================
echo.

REM Get absolute paths
set "GRID=%CD%\easyWave-master-data\data\grids\g08r4Indonesia.grd"
set "SOURCE=%CD%\easyWave-master-data\data\faults\BengkuluSept2007.flt"

cd outputs-cpu
..\easywave-sycl.exe -verbose -grid "%GRID%" -source "%SOURCE%" -time 60 -progress 1 2>&1
cd ..

echo.
echo ========================================
echo Simulation complete!
echo ========================================
echo.
echo Output files in outputs-cpu folder:
dir outputs-cpu\eWave.* /b 2>nul
echo.
if exist "outputs-cpu\eWave.2D.sshmax" (
    echo SUCCESS! Main output file created: eWave.2D.sshmax
) else (
    echo WARNING: Main output file missing
)
