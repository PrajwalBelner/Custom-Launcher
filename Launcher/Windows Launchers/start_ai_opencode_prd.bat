@echo off
setlocal EnableExtensions

<<<<<<< HEAD
REM Pre-Production OpenCode launcher for Windows.

set "BAT_DIR=%~dp0"

for %%I in ("%BAT_DIR%..") do (
    set "ROOT_DIR=%%~fI"
)

set "LINUX_LAUNCHER=%ROOT_DIR%\Linux Launchers\start_ai_opencode_prd.sh"
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
    echo ERROR: The Pre-Production Linux launcher was not found.
    echo.
=======
set "LINUX_LAUNCHER=%ROOT_DIR%\Linux Launchers\start_ai_opencode_prd.sh"
set "SHARED_LAUNCHER=%ROOT_DIR%\ai_open_opencode.sh"

if not exist "%LINUX_LAUNCHER%" (
    echo ERROR: Pre-Production Linux launcher was not found.
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
REM Use a project folder passed as the first argument.

if not "%~1"=="" (
    set "OPENCODE_PROJECT_DIR=%~f1"
    goto validate_project
)

REM Select the OpenCode project folder.

cls
echo ============================================================
echo AI OpenCode Launcher - Pre-Production
echo ============================================================
echo.
echo Server: prd@192.168.191.62
echo.
echo Select the project folder that OpenCode should work with.
echo.

set "OPENCODE_PROJECT_DIR="

for /f "usebackq delims=" %%I in (`powershell.exe -NoProfile -STA -Command "$shell = New-Object -ComObject Shell.Application; $folder = $shell.BrowseForFolder(0, 'Select the working folder for OpenCode Pre-Production', 0, 0); if ($null -ne $folder) { $folder.Self.Path }"`) do (
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

REM Clear any Development profile inherited from the parent shell.

set "OPENCODE_HOST_USER="

REM Display the selected configuration.

cls
echo ============================================================
echo AI OpenCode Launcher - Pre-Production
echo ============================================================
echo.
echo Server:  prd@192.168.191.62
echo Project: %OPENCODE_PROJECT_DIR%
echo.
echo Launcher package:
echo %ROOT_DIR%
echo.
echo Starting the SSH tunnels and opening OpenCode...
echo ============================================================
echo.

REM Start the Pre-Production Linux wrapper.
=======
echo ========================================
echo AI OpenCode Launcher - Pre-Production
echo ========================================
echo Server: prd@192.168.191.62
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

exit /b %RC%
``
=======
echo Launcher exited with code %RC%.
pause
exit /b %RC%
>>>>>>> dffd222 (Add files via upload)
