<<<<<<< HEAD
@echo off
setlocal EnableExtensions

<<<<<<< HEAD
REM Development OpenCode launcher for Windows.

set "BAT_DIR=%~dp0"

for %%I in ("%BAT_DIR%..") do (
    set "ROOT_DIR=%%~fI"
)

set "LINUX_LAUNCHER=%ROOT_DIR%\Linux Launchers\start_ai_opencode_dev.sh"
set "SHARED_LAUNCHER=%ROOT_DIR%\linux_start_opencode.sh"
set "SETTINGS_FILE=%ROOT_DIR%\scripts\lib\settings.sh"

REM Locate Git Bash.
=======
set "BAT_DIR=%~dp0"
for %%I in ("%BAT_DIR%..") do set "ROOT_DIR=%%~fI"
>>>>>>> dffd222 (Add files via upload)

set "GIT_BASH=C:\Program Files\Git\bin\bash.exe"

if not exist "%GIT_BASH%" (
    set "GIT_BASH=C:\Program Files\Git\usr\bin\bash.exe"
)

if not exist "%GIT_BASH%" (
    echo ERROR: Git Bash was not found.
<<<<<<< HEAD
    echo.
    echo Install Git for Windows and try again.
=======
    echo Install Git for Windows and retry.
>>>>>>> dffd222 (Add files via upload)
    pause
    exit /b 1
)

<<<<<<< HEAD
REM Validate the launcher package.

if not exist "%LINUX_LAUNCHER%" (
    echo ERROR: The Development Linux launcher was not found.
    echo.
=======
set "LINUX_LAUNCHER=%ROOT_DIR%\Linux Launchers\start_ai_opencode_dev.sh"
set "SHARED_LAUNCHER=%ROOT_DIR%\ai_open_opencode.sh"

if not exist "%LINUX_LAUNCHER%" (
    echo ERROR: Development Linux launcher was not found.
>>>>>>> dffd222 (Add files via upload)
    echo Expected:
    echo %LINUX_LAUNCHER%
    pause
    exit /b 1
)

if not exist "%SHARED_LAUNCHER%" (
<<<<<<< HEAD
    echo ERROR: The shared OpenCode launcher was not found.
    echo.
=======
    echo ERROR: Shared launcher was not found.
>>>>>>> dffd222 (Add files via upload)
    echo Expected:
    echo %SHARED_LAUNCHER%
    pause
    exit /b 1
)

<<<<<<< HEAD
if not exist "%SETTINGS_FILE%" (
    echo ERROR: The launcher library folder was not found.
    echo.
=======
if not exist "%ROOT_DIR%\scripts\lib\settings.sh" (
    echo ERROR: Launcher library folder was not found.
>>>>>>> dffd222 (Add files via upload)
    echo Expected:
    echo %ROOT_DIR%\scripts\lib
    pause
    exit /b 1
)

<<<<<<< HEAD
REM Select the Development SSH profile.

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
    goto select_project
)

if errorlevel 3 (
    set "OPENCODE_HOST_USER=ark"
    goto select_project
)

if errorlevel 2 (
    set "OPENCODE_HOST_USER=pgs"
    goto select_project
)

if errorlevel 1 (
    set "OPENCODE_HOST_USER=dhu"
    goto select_project
)

REM Select the OpenCode project folder.

:select_project

if not "%~1"=="" (
    set "OPENCODE_PROJECT_DIR=%~f1"
    goto validate_project
)

echo.
echo Select the folder that OpenCode should inspect and work with.
echo.

set "OPENCODE_PROJECT_DIR="

for /f "usebackq delims=" %%I in (`powershell.exe -NoProfile -STA -Command "$shell = New-Object -ComObject Shell.Application; $folder = $shell.BrowseForFolder(0, 'Select the working folder for OpenCode Development', 0, 0); if ($null -ne $folder) { $folder.Self.Path }"`) do (
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

REM Display the selected configuration.

cls
echo ============================================================
echo AI OpenCode Launcher - Development
echo ============================================================
echo.
echo Server:  %OPENCODE_HOST_USER%@192.168.191.61
echo Project: %OPENCODE_PROJECT_DIR%
echo.
echo Launcher package:
echo %ROOT_DIR%
echo.
echo Starting the SSH tunnels and opening OpenCode...
echo ============================================================
echo.

REM Start the Development Linux wrapper.
=======
echo ========================================
echo AI OpenCode Launcher - Development
echo ========================================
echo Server: pgs@192.168.191.61
echo Root:   %ROOT_DIR%
echo.
>>>>>>> dffd222 (Add files via upload)

"%GIT_BASH%" "%LINUX_LAUNCHER%"

set "RC=%ERRORLEVEL%"

echo.
<<<<<<< HEAD
echo ============================================================
echo Launcher exited with code %RC%.
echo ============================================================
pause

=======
echo Launcher exited with code %RC%.
pause
>>>>>>> dffd222 (Add files via upload)
exit /b %RC%
=======
@echo off
setlocal EnableExtensions

REM Development OpenCode launcher for Windows.

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

set "LINUX_LAUNCHER=%ROOT_DIR%Linux Launchers\start_ai_opencode_dev.sh"
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
if not exist "%LINUX_LAUNCHER%" (
    echo ERROR: The Development Linux launcher was not found.
    echo.
    echo Expected:
    echo %LINUX_LAUNCHER%
    pause
    exit /b 1
)

REM Select the Development SSH profile.

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
    goto profile_selected
)

if errorlevel 3 (
    set "OPENCODE_HOST_USER=ark"
    goto profile_selected
)

if errorlevel 2 (
    set "OPENCODE_HOST_USER=pgs"
    goto profile_selected
)

if errorlevel 1 (
    set "OPENCODE_HOST_USER=dhu"
    goto profile_selected
)

:profile_selected
set "SERVER_NAME=%OPENCODE_HOST_USER%@192.168.191.61"
set "PROJECT_STATE_DIR=%LOCALAPPDATA%\BremerAI\OpenCodeLauncher"
set "LAST_PROJECT_FILE=%PROJECT_STATE_DIR%\last-dev-project.txt"
set "FOLDER_PICKER_DESCRIPTION=Select the working folder for OpenCode Development"

cls
echo ============================================================
echo AI OpenCode Launcher - Development
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

REM Display the selected configuration.

cls
echo ============================================================
echo AI OpenCode Launcher - Development
echo ============================================================
echo.
echo Server:  %SERVER_NAME%
echo Project: %OPENCODE_PROJECT_DIR%
echo.
echo Launcher package:
echo %ROOT_DIR%
echo.
echo Starting the SSH tunnels and opening OpenCode...
echo ============================================================
echo.

REM Start the Development Linux wrapper.

"%GIT_BASH%" "%LINUX_LAUNCHER%"

set "RC=%ERRORLEVEL%"

echo.
echo ============================================================
echo Launcher exited with code %RC%.
echo ============================================================
pause

exit /b %RC%
>>>>>>> 3ebe8a0 (Add repository attributes and ignore rules)
