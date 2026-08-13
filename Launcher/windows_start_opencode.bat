@echo off
setlocal EnableExtensions

REM Shared Windows OpenCode launcher.

REM Locate the launcher root from the BAT file location.
REM This works from any current directory, shortcut, or Explorer launch,
REM provided the BAT file remains somewhere inside the launcher package.

set "SEARCH_DIR=%~dp0"

:find_launcher_root
if exist "%SEARCH_DIR%linux_start_opencode.sh" if exist "%SEARCH_DIR%scripts\lib\settings.sh" (
    set "ROOT_DIR=%SEARCH_DIR%"
    goto launcher_root_found
)

for %%I in ("%SEARCH_DIR%..") do set "PARENT_DIR=%%~fI\"

if /I "%PARENT_DIR%"=="%SEARCH_DIR%" (
    echo ERROR: The launcher root could not be located.
    echo.
    echo The BAT file must remain inside the launcher package.
    echo Expected launcher markers:
    echo   linux_start_opencode.sh
    echo   scripts\lib\settings.sh
    pause
    exit /b 1
)

set "SEARCH_DIR=%PARENT_DIR%"
goto find_launcher_root

:launcher_root_found

set "SHARED_LAUNCHER=%ROOT_DIR%linux_start_opencode.sh"
set "SETTINGS_FILE=%ROOT_DIR%scripts\lib\settings.sh"

REM Locate Git Bash.

set "GIT_BASH=C:\Program Files\Git\bin\bash.exe"

if not exist "%GIT_BASH%" (
    set "GIT_BASH=C:\Program Files\Git\usr\bin\bash.exe"
)

if not exist "%GIT_BASH%" (
    echo ERROR: Git Bash was not found.
    echo.
    echo Install Git for Windows and try again.
    pause
    exit /b 1
)

REM Validate the launcher package.

if not exist "%SHARED_LAUNCHER%" (
    echo ERROR: The shared OpenCode launcher was not found.
    echo.
    echo Expected:
    echo %SHARED_LAUNCHER%
    pause
    exit /b 1
)

if not exist "%SETTINGS_FILE%" (
    echo ERROR: The launcher library folder was not found.
    echo.
    echo Expected:
    echo %ROOT_DIR%scripts\lib
    pause
    exit /b 1
)

REM Select Development or Pre-Production.

cls
echo ============================================================
echo AI OpenCode Launcher
echo ============================================================
echo.
echo Select the server environment:
echo.
echo   1. Development
echo      192.168.191.61
echo.
echo   2. Pre-Production
echo      prd@192.168.191.62
echo.

choice /C 12 /N /M "Enter 1 or 2: "

if errorlevel 2 (
    set "ENVIRONMENT=prd"
    set "ENVIRONMENT_NAME=Pre-Production"
    set "SERVER_NAME=prd@192.168.191.62"
    set "OPENCODE_HOST_USER="
    goto environment_selected
)

if errorlevel 1 (
    set "ENVIRONMENT=dev"
    set "ENVIRONMENT_NAME=Development"
    goto select_development_profile
)

REM Select the Development SSH profile.

:select_development_profile

cls
echo ============================================================
echo AI OpenCode Launcher - Development
echo ============================================================
echo.
echo Server: 192.168.191.61
echo.
echo Select your Development SSH profile:
echo.
echo   1. dhu
echo   2. pgs
echo   3. ark
echo   4. tl
echo.

choice /C 1234 /N /M "Enter 1, 2, 3, or 4: "

if errorlevel 4 (
    set "OPENCODE_HOST_USER=tl"
    goto development_profile_selected
)

if errorlevel 3 (
    set "OPENCODE_HOST_USER=ark"
    goto development_profile_selected
)

if errorlevel 2 (
    set "OPENCODE_HOST_USER=pgs"
    goto development_profile_selected
)

if errorlevel 1 (
    set "OPENCODE_HOST_USER=dhu"
    goto development_profile_selected
)

:development_profile_selected
set "SERVER_NAME=%OPENCODE_HOST_USER%@192.168.191.61"

:environment_selected
set "PROJECT_STATE_DIR=%LOCALAPPDATA%\BremerAI\OpenCodeLauncher"
set "LAST_PROJECT_FILE=%PROJECT_STATE_DIR%\last-%ENVIRONMENT%-project.txt"
set "FOLDER_PICKER_DESCRIPTION=Select the project folder that OpenCode should work with"

cls
echo ============================================================
echo AI OpenCode Launcher - %ENVIRONMENT_NAME%
echo ============================================================
echo.
echo Server: %SERVER_NAME%
echo.
echo Select the project folder that OpenCode should work with.
echo The picker opens at the last project when that folder still exists.
echo.
if not exist "%PROJECT_STATE_DIR%\" (
    mkdir "%PROJECT_STATE_DIR%" >nul 2>&1
)

REM Use a project folder passed as the first argument.

if not "%~1"=="" (
    set "OPENCODE_PROJECT_DIR=%~f1"
    goto validate_project
)

set "OPENCODE_PROJECT_DIR="

for /f "usebackq delims=" %%I in (`powershell.exe -NoProfile -STA -Command "Add-Type -AssemblyName System.Windows.Forms; $initial = ''; if (Test-Path -LiteralPath $env:LAST_PROJECT_FILE -PathType Leaf) { $initial = [IO.File]::ReadAllText($env:LAST_PROJECT_FILE).Trim(); if (-not (Test-Path -LiteralPath $initial -PathType Container)) { $initial = '' } }; $dialog = New-Object System.Windows.Forms.FolderBrowserDialog; $dialog.Description = $env:FOLDER_PICKER_DESCRIPTION; $dialog.ShowNewFolderButton = $true; if ($initial) { $dialog.SelectedPath = $initial }; if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { $dialog.SelectedPath }"`) do (
    set "OPENCODE_PROJECT_DIR=%%I"
)

if not defined OPENCODE_PROJECT_DIR (
    echo.
    echo Folder selection was cancelled.
    exit /b 0
)

REM Validate the selected project folder.

:validate_project

if not defined OPENCODE_PROJECT_DIR (
    echo.
    echo ERROR: No project folder was selected.
    pause
    exit /b 1
)

if not exist "%OPENCODE_PROJECT_DIR%\" (
    echo.
    echo ERROR: The selected project folder was not found.
    echo.
    echo Selected folder:
    echo %OPENCODE_PROJECT_DIR%
    pause
    exit /b 1
)

REM Single remembered path. No project history is retained.

powershell.exe -NoProfile -Command "$dir = Split-Path -Parent $env:LAST_PROJECT_FILE; [IO.Directory]::CreateDirectory($dir) | Out-Null; [IO.File]::WriteAllText($env:LAST_PROJECT_FILE, $env:OPENCODE_PROJECT_DIR, (New-Object Text.UTF8Encoding($false)))"

if errorlevel 1 (
    echo.
    echo WARNING: The last project path could not be saved.
)

REM Display the selected environment and project.

cls
echo ============================================================
echo AI OpenCode Launcher - %ENVIRONMENT_NAME%
echo ============================================================
echo.
echo Server:  %SERVER_NAME%
echo Project: %OPENCODE_PROJECT_DIR%
echo.
echo Starting the SSH tunnels and opening OpenCode...
echo ============================================================
echo.

REM Start the shared Bash launcher.

"%GIT_BASH%" "%SHARED_LAUNCHER%" "%ENVIRONMENT%"

set "RC=%ERRORLEVEL%"

echo.
echo ============================================================
echo Launcher exited with code %RC%.
echo ============================================================
pause

exit /b %RC%
