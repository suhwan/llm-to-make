@echo off
setlocal enabledelayedexpansion

echo.
echo ========================================
echo   LLM-to-Make MCP Setup Script
echo   Automatic Installation for Users
echo ========================================
echo.

REM ========================================
REM Step 1: Check Node.js
REM ========================================
echo [1/5] Checking Node.js...

where node >nul 2>nul
if errorlevel 1 (
    echo.
    echo [ERROR] Node.js is not installed.
    echo.
    echo ========================================
    echo   How to Install Node.js
    echo ========================================
    echo.
    echo 1. Open https://nodejs.org/ in your browser
    echo 2. Click the "LTS" version download button
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
echo [2/5] Checking .env file...

set ENV_FILE=%~dp0.env
set ENV_TEMPLATE=%~dp0.env.template

if not exist "%ENV_FILE%" (
    if exist "%ENV_TEMPLATE%" (
        echo      [INFO] .env file not found.
        echo.
        echo      Copying .env.template to .env
        echo      Please enter your API keys.
        echo.
        copy "%ENV_TEMPLATE%" "%ENV_FILE%" >nul
        echo      [Created] .env file has been created.
        echo      Opening in Notepad - please enter your API keys.
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
set AIRTABLE_API_KEY=
set AIRTABLE_BASE_ID=
set GITHUB_TOKEN=
set MAKE_MCP_URL=

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
if "%AIRTABLE_API_KEY%"=="YOUR_AIRTABLE_API_KEY_HERE" goto :missing_key
if "%AIRTABLE_BASE_ID%"=="" goto :missing_key
if "%AIRTABLE_BASE_ID%"=="YOUR_BASE_ID_HERE" goto :missing_key
if "%MAKE_MCP_URL%"=="" goto :missing_key
if "%MAKE_MCP_URL%"=="YOUR_MAKE_MCP_URL_HERE" goto :missing_key

echo [OK] .env file verified
echo      - Airtable API Key: %AIRTABLE_API_KEY:~0,10%...
echo      - Airtable Base ID: %AIRTABLE_BASE_ID%
echo      - Make MCP URL: configured
if not "%GITHUB_TOKEN%"=="" echo      - GitHub Token: configured
echo.
goto :check_existing_mcp

:missing_key
echo      [ERROR] Required values missing in .env file.
echo.
echo      Please open .env file and enter:
echo      - AIRTABLE_API_KEY
echo      - AIRTABLE_BASE_ID
echo      - MAKE_MCP_URL
echo.
notepad "%ENV_FILE%"
echo      After entering values, run this script again.
pause
exit /b 1

:check_existing_mcp

REM ========================================
REM Step 3: Check existing .mcp.json and select MCPs
REM ========================================
echo [3/5] Checking MCP configuration...
echo.

set "MCP_JSON_PATH=%~dp0..\.mcp.json"
set INSTALL_MAKE=1
set INSTALL_AIRTABLE=1
set INSTALL_GITHUB=0
set INSTALL_GDRIVE=0
set INSTALL_PLAYWRIGHT=0

REM Check if .mcp.json exists and read current settings
if exist "%MCP_JSON_PATH%" (
    echo [FOUND] Existing .mcp.json detected
    echo.
    echo Current MCPs configured:

    REM Use Node.js to parse existing .mcp.json
    for /f "delims=" %%i in ('node -e "const fs=require('fs');try{const c=JSON.parse(fs.readFileSync('%MCP_JSON_PATH:\=\\%','utf8'));Object.keys(c.mcpServers||{}).forEach(k=>console.log(k));}catch(e){}"') do (
        echo   [x] %%i
        if "%%i"=="github" set INSTALL_GITHUB=1
        if "%%i"=="gdrive" set INSTALL_GDRIVE=1
        if "%%i"=="playwright-test" set INSTALL_PLAYWRIGHT=1
    )
    echo.
) else (
    echo [INFO] No existing .mcp.json found
    echo       Will create new configuration
    echo.
)

echo ========================================
echo   MCP Selection
echo ========================================
echo.
echo [Required - Always installed]
if %INSTALL_MAKE%==1 (echo   1. [x] Make.com     - Scenario management) else (echo   1. [ ] Make.com     - Scenario management)
if %INSTALL_AIRTABLE%==1 (echo   2. [x] Airtable     - Database management) else (echo   2. [ ] Airtable     - Database management)
echo.
echo [Optional - Toggle with numbers]
if %INSTALL_GITHUB%==1 (echo   3. [x] GitHub       - Repository management) else (echo   3. [ ] GitHub       - Repository management)
if %INSTALL_GDRIVE%==1 (echo   4. [x] Google Drive - File management) else (echo   4. [ ] Google Drive - File management)
if %INSTALL_PLAYWRIGHT%==1 (echo   5. [x] Playwright   - E2E testing) else (echo   5. [ ] Playwright   - E2E testing)
echo.
echo ----------------------------------------
echo Enter numbers to toggle ON/OFF (e.g., 3 4)
echo Press Enter to keep current selection
echo ----------------------------------------
echo.

set /p MCP_CHOICE="Toggle MCPs (e.g., 3 4 5) or press Enter: "

if not "%MCP_CHOICE%"=="" (
    echo %MCP_CHOICE% | findstr "3" >nul && (
        if %INSTALL_GITHUB%==1 (set INSTALL_GITHUB=0) else (set INSTALL_GITHUB=1)
    )
    echo %MCP_CHOICE% | findstr "4" >nul && (
        if %INSTALL_GDRIVE%==1 (set INSTALL_GDRIVE=0) else (set INSTALL_GDRIVE=1)
    )
    echo %MCP_CHOICE% | findstr "5" >nul && (
        if %INSTALL_PLAYWRIGHT%==1 (set INSTALL_PLAYWRIGHT=0) else (set INSTALL_PLAYWRIGHT=1)
    )
)

echo.
echo Final Selection:
echo   [x] Make.com
echo   [x] Airtable
if %INSTALL_GITHUB%==1 (echo   [x] GitHub) else (echo   [ ] GitHub)
if %INSTALL_GDRIVE%==1 (echo   [x] Google Drive) else (echo   [ ] Google Drive)
if %INSTALL_PLAYWRIGHT%==1 (echo   [x] Playwright) else (echo   [ ] Playwright)
echo.

REM ========================================
REM Step 4: Install packages
REM ========================================
echo [4/5] Installing packages...
echo      (This may take a few minutes)
echo.

REM Install Claude Code
echo   - Claude Code...
where claude >nul 2>nul
if errorlevel 1 (
    call npm install -g @anthropic-ai/claude-code >nul 2>nul
    echo     [OK] Installed
    echo.
    echo   - Claude Code authentication required
    echo     A browser will open for login...
    echo.
    call claude auth login
    echo.
) else (
    echo     [OK] Already installed
)

REM Install required MCPs
echo   - mcp-remote (Make.com)...
call npm install -g mcp-remote >nul 2>nul
echo     [OK]

echo   - airtable-mcp-server...
call npm install -g airtable-mcp-server >nul 2>nul
echo     [OK]

echo   - dotenv-cli...
call npm install -g dotenv-cli >nul 2>nul
echo     [OK]

REM Install optional MCPs
if %INSTALL_GITHUB%==1 (
    echo   - server-github...
    call npm install -g @modelcontextprotocol/server-github >nul 2>nul
    echo     [OK]
)

if %INSTALL_GDRIVE%==1 (
    echo   - mcp-gdrive...
    call npm install -g @isaacphi/mcp-gdrive >nul 2>nul
    echo     [OK]
)

if %INSTALL_PLAYWRIGHT%==1 (
    echo   - playwright...
    call npm install -g playwright >nul 2>nul
    echo     [OK]
)

echo.
echo [OK] All packages installed
echo.

REM ========================================
REM Step 5: Generate .mcp.json
REM ========================================
echo [5/5] Generating .mcp.json...
echo.

REM Backup existing .mcp.json
if exist "%MCP_JSON_PATH%" (
    copy /Y "%MCP_JSON_PATH%" "%MCP_JSON_PATH%.backup" >nul
    echo [BACKUP] Saved to .mcp.json.backup
)

REM Create Node.js script for JSON generation
set "SCRIPT_FILE=%TEMP%\generate_mcp.js"

echo const fs = require('fs'); > "%SCRIPT_FILE%"
echo const config = { mcpServers: {} }; >> "%SCRIPT_FILE%"
echo. >> "%SCRIPT_FILE%"
echo // Required: Make (uses wrapper to read URL from .env) >> "%SCRIPT_FILE%"
echo config.mcpServers.make = { >> "%SCRIPT_FILE%"
echo   command: 'node', >> "%SCRIPT_FILE%"
echo   args: ['install/make-mcp-wrapper.js'], >> "%SCRIPT_FILE%"
echo   description: 'Make.com scenario management' >> "%SCRIPT_FILE%"
echo }; >> "%SCRIPT_FILE%"
echo. >> "%SCRIPT_FILE%"
echo // Required: Airtable >> "%SCRIPT_FILE%"
echo config.mcpServers.airtable = { >> "%SCRIPT_FILE%"
echo   command: 'npx', >> "%SCRIPT_FILE%"
echo   args: ['-y', 'dotenv-cli', '-e', '.env', '--', 'npx', '-y', 'airtable-mcp-server'], >> "%SCRIPT_FILE%"
echo   description: 'Airtable data management' >> "%SCRIPT_FILE%"
echo }; >> "%SCRIPT_FILE%"

if %INSTALL_GITHUB%==1 (
    echo. >> "%SCRIPT_FILE%"
    echo // Optional: GitHub >> "%SCRIPT_FILE%"
    echo config.mcpServers.github = { >> "%SCRIPT_FILE%"
    echo   command: 'npx', >> "%SCRIPT_FILE%"
    echo   args: ['-y', 'dotenv-cli', '-e', '.env', '--', 'npx', '-y', '@modelcontextprotocol/server-github'], >> "%SCRIPT_FILE%"
    echo   description: 'GitHub repository management' >> "%SCRIPT_FILE%"
    echo }; >> "%SCRIPT_FILE%"
)

if %INSTALL_GDRIVE%==1 (
    echo. >> "%SCRIPT_FILE%"
    echo // Optional: Google Drive >> "%SCRIPT_FILE%"
    echo config.mcpServers.gdrive = { >> "%SCRIPT_FILE%"
    echo   command: 'npx', >> "%SCRIPT_FILE%"
    echo   args: ['-y', 'dotenv-cli', '-e', '.env', '--', 'npx', '-y', '@isaacphi/mcp-gdrive'], >> "%SCRIPT_FILE%"
    echo   description: 'Google Drive file management' >> "%SCRIPT_FILE%"
    echo }; >> "%SCRIPT_FILE%"
)

if %INSTALL_PLAYWRIGHT%==1 (
    echo. >> "%SCRIPT_FILE%"
    echo // Optional: Playwright >> "%SCRIPT_FILE%"
    echo config.mcpServers['playwright-test'] = { >> "%SCRIPT_FILE%"
    echo   command: 'npx', >> "%SCRIPT_FILE%"
    echo   args: ['playwright', 'run-test-mcp-server'], >> "%SCRIPT_FILE%"
    echo   description: 'E2E testing' >> "%SCRIPT_FILE%"
    echo }; >> "%SCRIPT_FILE%"
)

echo. >> "%SCRIPT_FILE%"
echo fs.writeFileSync('.mcp.json', JSON.stringify(config, null, 2)); >> "%SCRIPT_FILE%"
echo console.log('Generated .mcp.json'); >> "%SCRIPT_FILE%"

pushd %~dp0..
node "%SCRIPT_FILE%"
popd

del "%SCRIPT_FILE%" >nul 2>nul

if errorlevel 1 (
    echo [ERROR] Failed to create .mcp.json
) else (
    echo [OK] .mcp.json created in project root
)

echo.
echo ========================================
echo   Setup Complete!
echo ========================================
echo.
echo Configured MCPs:
echo   [x] Make.com
echo   [x] Airtable
if %INSTALL_GITHUB%==1 echo   [x] GitHub
if %INSTALL_GDRIVE%==1 echo   [x] Google Drive
if %INSTALL_PLAYWRIGHT%==1 echo   [x] Playwright
echo.
echo ========================================
echo   How to Use
echo ========================================
echo.
echo 1. Open terminal in this project folder
echo 2. Run: claude
echo 3. MCP tools will be loaded automatically
echo.
echo To reconfigure MCPs, run this script again.
echo.
echo ========================================
echo.
pause
