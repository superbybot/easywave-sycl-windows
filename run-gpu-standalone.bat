@echo off
REM Standalone GPU Mode Runner - No environment setup needed!

REM Add build directory to PATH for DLLs
set "PATH=%CD%\build;%PATH%"

echo Creating outputs-gpu directory...
if not exist "outputs-gpu" mkdir "outputs-gpu"

echo Deleting previous output files...
del /Q outputs-gpu\eWave.* 2>nul

echo.
echo Running simulation in GPU MODE (CUDA acceleration)...
echo ========================================
echo Start time: %date% %time%
echo ========================================
echo.

REM Record start time
set START_TIME=%time%

REM Get absolute paths
set "GRID=%CD%\easyWave-master-data\data\grids\g08r4Indonesia.grd"
set "SOURCE=%CD%\easyWave-master-data\data\faults\BengkuluSept2007.flt"

cd outputs-gpu
..\build\easywave-cuda.exe -gpu -verbose -grid "%GRID%" -source "%SOURCE%" -time 1440 -step 1 -progress 1
cd ..

echo.
echo ========================================
echo Simulation complete!
echo End time: %date% %time%
echo ========================================
echo.

REM Calculate elapsed time
set END_TIME=%time%
echo Start: %START_TIME%
echo End:   %END_TIME%

powershell -Command "$start = [datetime]::Parse('%START_TIME%'.Trim()); $end = [datetime]::Parse('%END_TIME%'.Trim()); $elapsed = $end - $start; if ($elapsed.TotalSeconds -lt 0) { $elapsed = $elapsed.Add([TimeSpan]::FromDays(1)) }; Write-Host ('Execution time: {0:D2}h {1:D2}m {2:D2}s' -f [int]$elapsed.TotalHours, $elapsed.Minutes, $elapsed.Seconds)"

if exist "outputs-gpu\eWave.2D.sshmax" (
    echo SUCCESS! Main output file created: eWave.2D.sshmax
) else (
    echo WARNING: Main output file missing
)
