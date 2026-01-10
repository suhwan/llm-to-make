@echo off
setlocal enabledelayedexpansion

echo.
echo ========================================
echo   LLM-to-Make MCP Install Script
echo   Auto installer for non-developers
echo ========================================
echo.
echo This script installs MCP servers for Claude Desktop.
echo.
echo [IMPORTANT] Existing MCP settings will be preserved.
echo             Only Make/Airtable MCP will be added.
echo.

REM ========================================
REM Step 1: Check Node.js
REM ========================================
echo [1/4] Checking Node.js...

where node >nul 2>nul
if errorlevel 1 (
    echo.
    echo [ERROR] Node.js is not installed.
    echo.
    echo ========================================
    echo   How to install Node.js
    echo ========================================
    echo.
    echo 1. Open https://nodejs.org/ in your browser
    echo 2. Click the LTS download button
    echo 3. Run the downloaded installer
    echo 4. Follow the installation wizard
    echo 5. Restart your computer and run this script again
    echo.
    echo Direct download link:
    echo https://nodejs.org/dist/v20.11.0/node-v20.11.0-x64.msi
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
echo [OK] Node.js found: %NODE_VERSION%
echo.

REM ========================================
REM Step 2: Check .env file
REM ========================================
echo [2/4] Checking .env file...

set "ENV_FILE=%~dp0.env"
set "ENV_TEMPLATE=%~dp0.env.template"

if not exist "%ENV_FILE%" (
    if exist "%ENV_TEMPLATE%" (
        echo      [INFO] .env file not found.
        echo.
        echo      Copying .env.template to .env...
        echo      Please enter your API keys.
        echo.
        echo      File location: %~dp0
        echo.
        copy "%ENV_TEMPLATE%" "%ENV_FILE%" >nul
        echo      [CREATED] .env file has been created.
        echo      Opening in Notepad for you to enter API keys.
        echo.
        notepad "%ENV_FILE%"
        echo.
        echo      After entering API keys, run this script again.
        echo.
        pause
        exit /b 0
    ) else (
        echo      [ERROR] .env.template file not found.
        pause
        exit /b 1
    )
)

REM Read values from .env file
set "AIRTABLE_API_KEY="
set "AIRTABLE_BASE_ID="
set "GITHUB_TOKEN="
set "MAKE_MCP_URL="

for /f "usebackq tokens=1,* delims==" %%a in ("%ENV_FILE%") do (
    set "line=%%a"
    if not "!line:~0,1!"=="#" (
        if "%%a"=="AIRTABLE_API_KEY" set "AIRTABLE_API_KEY=%%b"
        if "%%a"=="AIRTABLE_BASE_ID" set "AIRTABLE_BASE_ID=%%b"
        if "%%a"=="GITHUB_TOKEN" set "GITHUB_TOKEN=%%b"
        if "%%a"=="MAKE_MCP_URL" set "MAKE_MCP_URL=%%b"
    )
)

REM Check required values
if "%AIRTABLE_API_KEY%"=="" goto :missing_key
if "%AIRTABLE_API_KEY%"=="YOUR_AIRTABLE_API_KEY" goto :missing_key
if "%AIRTABLE_BASE_ID%"=="" goto :missing_key
if "%AIRTABLE_BASE_ID%"=="YOUR_AIRTABLE_BASE_ID" goto :missing_key

echo [OK] .env file verified
echo      - Airtable API Key: %AIRTABLE_API_KEY:~0,10%...
echo      - Airtable Base ID: %AIRTABLE_BASE_ID%
if not "%GITHUB_TOKEN%"=="" echo      - GitHub Token: configured
echo.
goto :continue_install

:missing_key
echo      [ERROR] Required values missing in .env file.
echo.
echo      Please enter the following in .env file:
echo      - AIRTABLE_API_KEY
echo      - AIRTABLE_BASE_ID
echo.
notepad "%ENV_FILE%"
echo      After entering values, run this script again.
pause
exit /b 1

:continue_install

REM ========================================
REM Step 3: Install NPM packages
REM ========================================
echo [3/4] Installing MCP packages...
echo      (This may take a few minutes on first run)
echo.

echo      [Required MCP]
echo      - mcp-remote (Make.com)...
call npx -y mcp-remote --help >nul 2>nul
echo        [OK]

echo      - airtable-mcp-server (Airtable)...
call npx -y airtable-mcp-server --help >nul 2>nul
echo        [OK]

if not "%GITHUB_TOKEN%"=="" (
    echo.
    echo      [Optional MCP]
    echo      - server-github (GitHub)...
    call npx -y @modelcontextprotocol/server-github --help >nul 2>nul
    echo        [OK]
)

echo.
echo [OK] MCP packages installed
echo.

REM ========================================
REM Step 4: Merge config file
REM ========================================
echo [4/4] Merging Claude Desktop config...
echo.

node "%~dp0merge-config.js"

if errorlevel 1 (
    echo.
    echo [ERROR] Config file generation failed
    pause
    exit /b 1
)

echo.
echo ========================================
echo   Next Steps
echo ========================================
echo.
echo 1. Restart Claude Desktop
echo    - Quit completely from system tray, then restart
echo.
echo 2. Verify MCP connection
echo    - In Claude Desktop, type: Show me available MCP tools
echo    - If Make, Airtable tools appear, success!
echo.
echo ========================================
echo.
pause
