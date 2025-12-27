@echo off
REM CPU Mode Runner - Guaranteed to work!

echo Initializing Intel oneAPI environment...
call "C:\Program Files (x86)\Intel\oneAPI\setvars.bat"

echo.
echo Creating outputs-cpu directory...
if not exist "outputs-cpu" mkdir "outputs-cpu"

echo Deleting previous output files...
del /Q outputs-cpu\eWave.* 2>nul

echo.
echo Running simulation in CPU MODE (no GPU acceleration)...
echo ========================================
echo Start time: %date% %time%
echo ========================================
echo.

REM Record start time
set START_TIME=%time%

REM Get absolute paths
set "GRID=%CD%\easyWave-master-data\data\grids\g08r4Indonesia.grd"
set "SOURCE=%CD%\easyWave-master-data\data\faults\BengkuluSept2007.flt"

cd outputs-cpu
..\easywave-sycl.exe -verbose -grid "%GRID%" -source "%SOURCE%" -time 1440 -step 1 -progress 1
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

REM Calculate execution time using PowerShell
powershell -Command "$start = [datetime]::ParseExact('%START_TIME%', 'HH:mm:ss.ff', $null); $end = [datetime]::ParseExact('%END_TIME%', 'HH:mm:ss.ff', $null); $elapsed = $end - $start; if ($elapsed.TotalSeconds -lt 0) { $elapsed = $elapsed.Add([TimeSpan]::FromDays(1)) }; Write-Host ('Execution time: {0:D2}h {1:D2}m {2:D2}s' -f [int]$elapsed.TotalHours, $elapsed.Minutes, $elapsed.Seconds)"

if exist "outputs-cpu\eWave.2D.sshmax" (
    echo SUCCESS! Main output file created: eWave.2D.sshmax
) else (
    echo WARNING: Main output file missing
)
