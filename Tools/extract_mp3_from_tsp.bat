@echo off
setlocal enabledelayedexpansion

:: ==============================
:: Drag-and-Drop Dish .TSP/.DVT to MP3 Extractor
:: Requires: FFmpeg (auto-download if missing)
:: ==============================

:: FFmpeg download URL (Windows static build)
set "FFMPEG_URL=https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
set "FFMPEG_DIR=%~dp0ffmpeg"
set "FFMPEG_EXE=%FFMPEG_DIR%\bin\ffmpeg.exe"

echo.
echo ============================================
echo  Dish Network .TSP/.DVT to MP3 Extractor
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

:: Step 2: Process each dropped file
if "%~1"=="" (
    echo No files provided. Please drag and drop .tsp or .dvt files onto this script.
    pause
    exit /b
)

set "COUNT=0"
for %%F in (%*) do (
    if exist "%%~F" (
        set /a COUNT+=1
        set "INPUT=%%~F"
        set "BASENAME=%%~nF"
        set "DIRNAME=%%~dpF"
        set "OUTPUT=!DIRNAME!!BASENAME!.mp3"

        echo Extracting MP3 from "!INPUT!"...
        "%FFMPEG_EXE%" -hide_banner -loglevel error -i "!INPUT!" -vn -acodec libmp3lame -q:a 2 "!OUTPUT!" || (
            echo ERROR extracting from "!INPUT!" >> "%~dp0mp3_extraction_errors.log"
        )
    )
)

echo.
echo Extraction complete. %COUNT% file(s) processed.
if exist "%~dp0mp3_extraction_errors.log" (
    echo Some files failed. See mp3_extraction_errors.log for details.
)

pause
endlocal
