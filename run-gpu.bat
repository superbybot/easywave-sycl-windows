@echo off
REM GPU Mode Runner - Uses CUDA executable with GPU acceleration

echo Creating outputs-gpu directory...
if not exist "outputs-gpu" mkdir "outputs-gpu"

echo.
echo Running simulation in GPU MODE (CUDA acceleration)...
echo ========================================
echo.

REM Get absolute paths
set "GRID=%CD%\easyWave-master-data\data\grids\g08r4Indonesia.grd"
set "SOURCE=%CD%\easyWave-master-data\data\faults\BengkuluSept2007.flt"

cd outputs-gpu
..\easywave-cuda.exe -gpu -verbose -grid "%GRID%" -source "%SOURCE%" -time 60 -progress 1 2>&1
cd ..

echo.
echo ========================================
echo Simulation complete!
echo ========================================
echo.
echo Output files in outputs-gpu folder:
dir outputs-gpu\eWave.* /b 2>nul
echo.
if exist "outputs-gpu\eWave.2D.sshmax" (
    echo SUCCESS! Main output file created: eWave.2D.sshmax
) else (
    echo WARNING: Main output file missing
)
