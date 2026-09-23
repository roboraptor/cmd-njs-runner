@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Colors
for /f "delims=" %%a in ('powershell -NoProfile -Command "[char]27"') do set "ESC=%%a"
if not defined ESC (
    for /f "tokens=27 delims=" %%a in ('choice /c a /t 1 /d a /n ^<nul') do set "ESC= %%a"
    set "ESC=!ESC:~-1!"
)
set "RED=%ESC%[91m"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "BLUE=%ESC%[94m"
set "CYAN=%ESC%[96m"
set "GRAY=%ESC%[90m"
set "BOLD=%ESC%[1m"
set "RESET=%ESC%[0m"

:menu
cls
echo %BLUE%===================================================================%RESET%
echo %BLUE%* %BOLD%ProjectRunner INI Creator%RESET%
echo %BLUE%===================================================================%RESET%
echo.

set "ini_exists=0"
if exist "ProjectRunner.ini" set "ini_exists=1"

echo   [%CYAN%1%RESET%] Import from package.json
echo   [%CYAN%2%RESET%] Create manually
if !ini_exists!==1 (
    echo   [%CYAN%3%RESET%] Edit ProjectRunner.ini
    echo   [%CYAN%4%RESET%] Show ProjectRunner.ini
) else (
    echo   %GRAY%[3] Edit ProjectRunner.ini ^(Not found^)%RESET%
    echo   %GRAY%[4] Show ProjectRunner.ini ^(Not found^)%RESET%
)
echo   [%CYAN%0%RESET%] Exit
echo.

set "choice="
set /p choice="Enter selection [1, 2, 3, 4, 0]: "
if defined choice set "choice=!choice: =!"

if "%choice%"=="1" goto opt_import
if "%choice%"=="2" goto opt_manual
if "%choice%"=="3" (
    if !ini_exists!==1 goto opt_edit
)
if "%choice%"=="4" (
    if !ini_exists!==1 goto opt_show
)
if "%choice%"=="0" exit /b 0

goto menu

:opt_import
cls
echo %BLUE%===================================================================%RESET%
echo %BOLD%Import from package.json%RESET%
echo %BLUE%===================================================================%RESET%
echo.

if not exist "package.json" (
    echo %YELLOW%[WARN] 'package.json' not found in the current directory.%RESET%
    echo Cannot extract project information.
    echo.
    pause
    goto menu
)

echo Reading package.json...
set "PKG_NAME="
set "PKG_DESC="

for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "$j = Get-Content 'package.json' -Raw | ConvertFrom-Json; if($null -ne $j.name){ $j.name }" 2^>nul`) do (
    set "PKG_NAME=%%I"
)
for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "$j = Get-Content 'package.json' -Raw | ConvertFrom-Json; if($null -ne $j.description){ $j.description }" 2^>nul`) do (
    set "PKG_DESC=%%I"
)

set "GEN_TITLE=!PKG_NAME!"
set "GEN_SUBTITLE=!PKG_DESC!"
set "GEN_DEVURL="
set "GEN_PRODURL="
set "GEN_OPENBROWSER=true"
set "GEN_BUILDDIR="
set "GEN_DEVCMD=npm run dev"
set "GEN_BUILDCMD=npm run build"
set "GEN_PRODCMD=npm run start"
set "GEN_INSTALLCMD=npm install"
set "FORCE_OVERWRITE=0"

call :generate_ini
pause
goto menu

:opt_manual
cls
echo %BLUE%===================================================================%RESET%
echo %BOLD%Create manually%RESET%
echo %BLUE%===================================================================%RESET%
echo.

set "GEN_TITLE="
set /p GEN_TITLE="Project Title: "

set "GEN_SUBTITLE="
set /p GEN_SUBTITLE="Project Subtitle (Description): "

echo.
echo Select Development Port:
echo   [%CYAN%1%RESET%] 3000 (Next.js, Create React App)
echo   [%CYAN%2%RESET%] 5173 (Vite)
echo   [%CYAN%3%RESET%] Custom
echo.
set "port_choice="
set /p port_choice="Selection [1, 2, 3]: "

set "GEN_DEVURL="
set "GEN_PRODURL="

if "%port_choice%"=="1" (
    set "GEN_DEVURL=http://localhost:3000"
    set "GEN_PRODURL=http://localhost:3000"
) else if "%port_choice%"=="2" (
    set "GEN_DEVURL=http://localhost:5173"
    set "GEN_PRODURL=http://localhost:5173"
) else if "%port_choice%"=="3" (
    set "MAN_PORT="
    set /p MAN_PORT="Enter custom port number (e.g. 8080): "
    set "GEN_DEVURL=http://localhost:!MAN_PORT!"
    set "GEN_PRODURL=http://localhost:!MAN_PORT!"
)

:: Browser open prompt
set "GEN_OPENBROWSER=true"
echo.
set "ask_browser="
set /p ask_browser="Automatically open web browser on start? [Y/N] (default Y): "
if /i "!ask_browser!"=="N" set "GEN_OPENBROWSER=false"

:: Build dir prompt
set "GEN_BUILDDIR="
echo.
set "ask_build="
set /p ask_build="Specify custom build directory? [Y/N] (default N): "
if /i "!ask_build!"=="Y" (
    set /p GEN_BUILDDIR="Build Directory (e.g. build, dist, .next): "
)

:: Commands prompt
set "GEN_DEVCMD=npm run dev"
set "GEN_BUILDCMD=npm run build"
set "GEN_PRODCMD=npm run start"
set "GEN_INSTALLCMD=npm install"

echo.
set "ask_cmds="
set /p ask_cmds="Edit custom NPM commands? [Y/N] (default N): "
if /i "!ask_cmds!"=="Y" (
    echo.
    echo %GRAY%Leave blank to keep the default value.%RESET%
    set "tmp_dev="
    set /p tmp_dev="Dev Command [!GEN_DEVCMD!]: "
    if defined tmp_dev set "GEN_DEVCMD=!tmp_dev!"
    
    set "tmp_bld="
    set /p tmp_bld="Build Command [!GEN_BUILDCMD!]: "
    if defined tmp_bld set "GEN_BUILDCMD=!tmp_bld!"
    
    set "tmp_prd="
    set /p tmp_prd="Prod Command [!GEN_PRODCMD!]: "
    if defined tmp_prd set "GEN_PRODCMD=!tmp_prd!"
    
    set "tmp_ins="
    set /p tmp_ins="Install Command [!GEN_INSTALLCMD!]: "
    if defined tmp_ins set "GEN_INSTALLCMD=!tmp_ins!"
)

set "FORCE_OVERWRITE=0"
call :generate_ini
pause
goto menu

:opt_edit
cls
echo %BLUE%===================================================================%RESET%
echo %BOLD%Edit ProjectRunner.ini%RESET%
echo %BLUE%===================================================================%RESET%
echo.
echo %GRAY%Leave blank to keep the current value.%RESET%
echo.
call :load_ini

set "GEN_TITLE=!CFG_TITLE!"
set "tmp_val="
set /p tmp_val="Project Title [!GEN_TITLE!]: "
if defined tmp_val set "GEN_TITLE=!tmp_val!"

set "GEN_SUBTITLE=!CFG_SUBTITLE!"
set "tmp_val="
set /p tmp_val="Project Subtitle [!GEN_SUBTITLE!]: "
if defined tmp_val set "GEN_SUBTITLE=!tmp_val!"

set "GEN_DEVURL=!CFG_DEV_URL!"
set "tmp_val="
set /p tmp_val="Dev URL [!GEN_DEVURL!]: "
if defined tmp_val set "GEN_DEVURL=!tmp_val!"

set "GEN_PRODURL=!CFG_PROD_URL!"
set "tmp_val="
set /p tmp_val="Prod URL [!GEN_PRODURL!]: "
if defined tmp_val set "GEN_PRODURL=!tmp_val!"

set "GEN_OPENBROWSER=!CFG_OPEN_BROWSER!"
if not defined GEN_OPENBROWSER set "GEN_OPENBROWSER=true"
set "tmp_val="
set /p tmp_val="Open Browser on start (true/false) [!GEN_OPENBROWSER!]: "
if defined tmp_val set "GEN_OPENBROWSER=!tmp_val!"

set "GEN_BUILDDIR=!CFG_BUILD_DIR!"
set "tmp_val="
set /p tmp_val="Build Directory [!GEN_BUILDDIR!]: "
if defined tmp_val set "GEN_BUILDDIR=!tmp_val!"

set "GEN_DEVCMD=!CFG_DEV_CMD!"
if not defined GEN_DEVCMD set "GEN_DEVCMD=npm run dev"
set "tmp_val="
set /p tmp_val="Dev Command [!GEN_DEVCMD!]: "
if defined tmp_val set "GEN_DEVCMD=!tmp_val!"

set "GEN_BUILDCMD=!CFG_BUILD_CMD!"
if not defined GEN_BUILDCMD set "GEN_BUILDCMD=npm run build"
set "tmp_val="
set /p tmp_val="Build Command [!GEN_BUILDCMD!]: "
if defined tmp_val set "GEN_BUILDCMD=!tmp_val!"

set "GEN_PRODCMD=!CFG_PROD_CMD!"
if not defined GEN_PRODCMD set "GEN_PRODCMD=npm run start"
set "tmp_val="
set /p tmp_val="Prod Command [!GEN_PRODCMD!]: "
if defined tmp_val set "GEN_PRODCMD=!tmp_val!"

set "GEN_INSTALLCMD=!CFG_INSTALL_CMD!"
if not defined GEN_INSTALLCMD set "GEN_INSTALLCMD=npm install"
set "tmp_val="
set /p tmp_val="Install Command [!GEN_INSTALLCMD!]: "
if defined tmp_val set "GEN_INSTALLCMD=!tmp_val!"

set "FORCE_OVERWRITE=1"
call :generate_ini
pause
goto menu

:opt_show
cls
call :load_ini
echo %GRAY%Preview of how ProjectRunner.bat will see your configuration:%RESET%
echo.
echo %BLUE%===================================================================%RESET%
if defined CFG_TITLE (
    echo %BLUE%* %BOLD%!CFG_TITLE!%RESET%%BLUE% %RESET%
) else (
    echo %BLUE%* %BOLD%^<Auto-detected Title^>%RESET%%BLUE% %RESET%
)
if defined CFG_SUBTITLE (
    echo %GRAY%  !CFG_SUBTITLE!%RESET%
) else (
    echo %GRAY%  ^<Auto-detected Subtitle^>%RESET%
)
echo %GRAY%  Directory: %CD%%RESET%
echo %BLUE%===================================================================%RESET%
echo.
echo %BOLD%Configured Overrides:%RESET%
if defined CFG_DEV_URL echo   Dev URL        : %CYAN%!CFG_DEV_URL!%RESET%
if defined CFG_PROD_URL echo   Prod URL       : %CYAN%!CFG_PROD_URL!%RESET%
if defined CFG_OPEN_BROWSER echo   Open Browser   : %CYAN%!CFG_OPEN_BROWSER!%RESET%
if defined CFG_BUILD_DIR echo   Build Dir      : %CYAN%!CFG_BUILD_DIR!%RESET%
if defined CFG_DEV_CMD echo   Dev Command    : %CYAN%!CFG_DEV_CMD!%RESET%
if defined CFG_BUILD_CMD echo   Build Command  : %CYAN%!CFG_BUILD_CMD!%RESET%
if defined CFG_PROD_CMD echo   Prod Command   : %CYAN%!CFG_PROD_CMD!%RESET%
if defined CFG_INSTALL_CMD echo   Install Command: %CYAN%!CFG_INSTALL_CMD!%RESET%
echo.
echo %BLUE%===================================================================%RESET%
pause
goto menu

:load_ini
set "CFG_TITLE="
set "CFG_SUBTITLE="
set "CFG_DEV_URL="
set "CFG_PROD_URL="
set "CFG_OPEN_BROWSER="
set "CFG_BUILD_DIR="
set "CFG_DEV_CMD="
set "CFG_BUILD_CMD="
set "CFG_PROD_CMD="
set "CFG_INSTALL_CMD="

if not exist "ProjectRunner.ini" exit /b

for /f "usebackq eol=; tokens=1,* delims==" %%A in ("ProjectRunner.ini") do (
    set "k=%%A"
    set "v=%%B"
    for /f "tokens=* delims= " %%K in ("!k!") do set "k=%%K"
    set "chk=!k:~0,1!"
    if not "!chk!"=="[" if not "!chk!"=="#" (
        if defined v for /f "tokens=* delims= " %%V in ("!v!") do set "v=%%V"
        for /l %%i in (1,1,10) do if "!k:~-1!"==" " set "k=!k:~0,-1!"

        if /i "!k!"=="Title" set "CFG_TITLE=!v!"
        if /i "!k!"=="Subtitle" set "CFG_SUBTITLE=!v!"
        if /i "!k!"=="DevUrl" set "CFG_DEV_URL=!v!"
        if /i "!k!"=="ProdUrl" set "CFG_PROD_URL=!v!"
        if /i "!k!"=="OpenBrowser" set "CFG_OPEN_BROWSER=!v!"
        if /i "!k!"=="BuildDir" set "CFG_BUILD_DIR=!v!"
        if /i "!k!"=="DevCommand" set "CFG_DEV_CMD=!v!"
        if /i "!k!"=="BuildCommand" set "CFG_BUILD_CMD=!v!"
        if /i "!k!"=="ProdCommand" set "CFG_PROD_CMD=!v!"
        if /i "!k!"=="InstallCommand" set "CFG_INSTALL_CMD=!v!"
    )
)
exit /b

:generate_ini
if exist "ProjectRunner.ini" (
    if not "!FORCE_OVERWRITE!"=="1" (
        echo.
        echo %YELLOW%[WARN] 'ProjectRunner.ini' already exists!%RESET%
        set /p overwrite="Do you want to overwrite it? [Y/N]: "
        if /i not "!overwrite!"=="Y" (
            echo Operation cancelled.
            exit /b
        )
    )
)

(
echo ; ===================================================================
echo ; ProjectRunner Configuration File ^(Optional configuration file^)
echo ; ===================================================================
echo ; Generated by PR-ini-creator.bat
echo ; ===================================================================
echo.
echo [Project]
echo ; Project title displayed in the header
echo Title=!GEN_TITLE!
echo.
echo ; Subtitle or a short project description
echo Subtitle=!GEN_SUBTITLE!
echo.
echo [Server]
echo ; URL for the development server ^(default: http://localhost:5173 for Vite, otherwise http://localhost:3000^)
echo DevUrl=!GEN_DEVURL!
echo.
echo ; URL for the production server
echo ProdUrl=!GEN_PRODURL!
echo.
echo ; Automatically open the web browser when starting dev/prod server? ^(true / false^)
echo OpenBrowser=!GEN_OPENBROWSER!
echo.
echo [Build]
echo ; The folder where the production build is generated ^(e.g., dist, .next, build, out^)
echo BuildDir=!GEN_BUILDDIR!
echo.
echo [Commands]
echo ; Custom commands for individual actions ^(if different from the defaults^)
echo DevCommand=!GEN_DEVCMD!
echo BuildCommand=!GEN_BUILDCMD!
echo ProdCommand=!GEN_PRODCMD!
echo InstallCommand=!GEN_INSTALLCMD!
) > "ProjectRunner.ini"
echo.
echo %GREEN%[✓] ProjectRunner.ini updated successfully!%RESET%
exit /b
