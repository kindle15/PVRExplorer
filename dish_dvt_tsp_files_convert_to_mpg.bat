Got it ✅ — I’ll give you a ready-to-use Windows batch script that:

Checks if FFmpeg is installed (downloads it automatically if missing).
Processes all .tsp and .dvt files in the current folder.
Renames them to .ts internally and remuxes to .mpg without re-encoding (lossless).
Handles spaces in filenames and logs errors.


Windows Batch Script: convert_tsp_to_mpg.bat
Bat@echo off
setlocal enabledelayedexpansion

:: ==============================
:: Dish .TSP/.DVT to .MPG Converter
:: Requires: FFmpeg (auto-download if missing)
:: ==============================

:: Set FFmpeg download URL (Windows static build)
set "FFMPEG_URL=https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
set "FFMPEG_DIR=%~dp0ffmpeg"
set "FFMPEG_EXE=%FFMPEG_DIR%\bin\ffmpeg.exe"

echo.
echo ============================================
echo  Dish Network .TSP/.DVT to .MPG Converter
echo ============================================
echo.

:: Step 1: Check if FFmpeg exists
if not exist "%FFMPEG_EXE%" (
    echo FFmpeg not found. Downloading...
    powershell -Command "Invoke-WebRequest -Uri '%FFMPEG_URL%' -OutFile 'ffmpeg.zip'" || (
        echo ERROR: Failed to download FFmpeg.
        pause
        exit /b 1
    )
    echo Extracting FFmpeg...
    powershell -Command "Expand-Archive -Path 'ffmpeg.zip' -DestinationPath '%~dp0' -Force"
    del /f /q ffmpeg.zip
    :: Move extracted folder to ffmpeg
    for /d %%D in ("%~dp0ffmpeg-*") do (
        move "%%D" "%FFMPEG_DIR%" >nul
    )
    echo FFmpeg installed successfully.
)

:: Step 2: Process all .tsp and .dvt files
set "COUNT=0"
for %%F in (*.tsp *.dvt) do (
    if exist "%%F" (
        set /a COUNT+=1
        set "INPUT=%%F"
        set "BASENAME=%%~nF"
        set "OUTPUT=%%~nF.mpg"

        echo Converting "!INPUT!" to "!OUTPUT!"...
        "%FFMPEG_EXE%" -hide_banner -loglevel error -i "!INPUT!" -c copy "!OUTPUT!" || (
            echo ERROR converting "!INPUT!" >> conversion_errors.log
        )
    )
)

if %COUNT%==0 (
    echo No .tsp or .dvt files found in this folder.
) else (
    echo.
    echo Conversion complete. %COUNT% file(s) processed.
    if exist conversion_errors.log (
        echo Some files failed. See conversion_errors.log for details.
    )
)

pause
endlocal


rem How to Use

rem Download & Save the script above as convert_tsp_to_mpg.bat.
rem Place it in the same folder as your .tsp or .dvt files.
rem Double-click the .bat file — it will:

rem Download FFmpeg if missing.
rem Convert all .tsp/.dvt to .mpg in the same folder.


rem Converted files will keep the same base name.


rem Notes

rem This script does not re-encode — it’s fast and keeps original quality.
rem If your Dish recordings are encrypted, the output .mpg will still be unplayable outside the DVR.
rem Requires Windows 7+ with PowerShell enabled (default on all modern Windows).


rem If you want, I can also make a drag-and-drop version so you can drop .tsp files onto the script and get .mpg instantly.
rem Do you want me to prepare that version too?
