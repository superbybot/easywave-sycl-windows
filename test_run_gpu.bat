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

REM Get absolute paths from realdata directory
set "GRID=%CD%\easyWave-master-data\data\realdata\Philippines_2m_Bathy.grd"


REM set "GRID=%CD%\easyWave-master-data\data\realdata\GEBCO_Nothern_Phil_15s.grd"
set "SOURCE=%CD%\easyWave-master-data\data\realdata\Phil_Trench_06.flt"
set "POI=%CD%\easyWave-master-data\data\realdata\Aurora.poi"

cd outputs-gpu
..\build\easywave-cuda.exe -gpu -verbose -grid "%GRID%" -source "%SOURCE%" -poi "%POI%" -time 480 -step 1 -progress 1
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

powershell -Command "$start = [datetime]::ParseExact('%START_TIME%', 'HH:mm:ss.ff', $null); $end = [datetime]::ParseExact('%END_TIME%', 'HH:mm:ss.ff', $null); $elapsed = $end - $start; if ($elapsed.TotalSeconds -lt 0) { $elapsed = $elapsed.Add([TimeSpan]::FromDays(1)) }; $totalMinutes = [int]$elapsed.TotalMinutes; $seconds = $elapsed.Seconds; Write-Host ('Elapsed time: {0}m {1:D2}s ({2:F1} minutes)' -f $totalMinutes, $seconds, $elapsed.TotalMinutes)"

if exist "outputs-gpu\eWave.2D.sshmax" (
    echo SUCCESS! Main output file created: eWave.2D.sshmax
) else (
    echo WARNING: Main output file missing
)

PAUSE
