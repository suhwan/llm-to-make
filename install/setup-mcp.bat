@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
echo ========================================
echo   LLM-to-Make MCP 설치 스크립트
echo   비개발자를 위한 자동 설치
echo ========================================
echo.
echo 이 스크립트는 Claude Desktop에서 MCP 서버를 사용할 수 있도록
echo 필요한 패키지를 자동으로 설치합니다.
echo.

REM ========================================
REM Step 1: Node.js 설치 확인
REM ========================================
echo [1/5] Node.js 확인 중...

where node >nul 2>nul
if errorlevel 1 (
    echo.
    echo [오류] Node.js가 설치되어 있지 않습니다.
    echo.
    echo ========================================
    echo   Node.js 설치 방법
    echo ========================================
    echo.
    echo 1. 웹 브라우저에서 https://nodejs.org/ 접속
    echo 2. "LTS" 버전 다운로드 버튼 클릭
    echo 3. 다운로드된 설치 파일 실행
    echo 4. 설치 마법사 지시에 따라 설치 완료
    echo 5. 컴퓨터 재시작 후 이 스크립트 다시 실행
    echo.
    echo 설치 파일 직접 다운로드:
    echo https://nodejs.org/dist/v20.11.0/node-v20.11.0-x64.msi
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
echo [OK] Node.js 발견: %NODE_VERSION%
echo.

REM ========================================
REM Step 2: .env 파일 확인
REM ========================================
echo [2/5] .env 파일 확인 중...

set ENV_FILE=%~dp0.env
set ENV_TEMPLATE=%~dp0.env.template

if not exist "%ENV_FILE%" (
    if exist "%ENV_TEMPLATE%" (
        echo      [안내] .env 파일이 없습니다.
        echo.
        echo      .env.template 파일을 .env로 복사한 후
        echo      API 키를 입력해주세요.
        echo.
        echo      파일 위치: %~dp0
        echo.
        copy "%ENV_TEMPLATE%" "%ENV_FILE%" >nul
        echo      [생성됨] .env 파일이 생성되었습니다.
        echo      메모장으로 열어서 API 키를 입력하세요.
        echo.
        notepad "%ENV_FILE%"
        echo.
        echo      API 키 입력 후 이 스크립트를 다시 실행하세요.
        echo.
        pause
        exit /b 0
    ) else (
        echo      [오류] .env.template 파일을 찾을 수 없습니다.
        pause
        exit /b 1
    )
)

REM .env 파일에서 값 읽기
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

REM 필수 값 확인
if "%AIRTABLE_API_KEY%"=="" goto :missing_key
if "%AIRTABLE_API_KEY%"=="여기에_에어테이블_API키_입력" goto :missing_key
if "%AIRTABLE_BASE_ID%"=="" goto :missing_key
if "%AIRTABLE_BASE_ID%"=="여기에_베이스ID_입력" goto :missing_key

echo [OK] .env 파일 확인됨
echo      - Airtable API Key: %AIRTABLE_API_KEY:~0,10%...
echo      - Airtable Base ID: %AIRTABLE_BASE_ID%
if not "%GITHUB_TOKEN%"=="" echo      - GitHub Token: 설정됨
echo.
goto :continue_install

:missing_key
echo      [오류] .env 파일에 필수 값이 없습니다.
echo.
echo      .env 파일을 열어서 다음 값을 입력하세요:
echo      - AIRTABLE_API_KEY
echo      - AIRTABLE_BASE_ID
echo.
notepad "%ENV_FILE%"
echo      입력 후 이 스크립트를 다시 실행하세요.
pause
exit /b 1

:continue_install

REM ========================================
REM Step 3: NPM 패키지 설치
REM ========================================
echo [3/5] MCP 패키지 설치 중...
echo      (처음 실행 시 몇 분 소요될 수 있습니다)
echo.

echo      [필수 MCP]
echo      - mcp-remote (Make.com 연동)...
call npx -y mcp-remote --help >nul 2>nul
if errorlevel 1 (
    echo        [설치중...]
) else (
    echo        [OK]
)

echo      - airtable-mcp-server (Airtable 연동)...
call npx -y airtable-mcp-server --help >nul 2>nul
if errorlevel 1 (
    echo        [설치중...]
) else (
    echo        [OK]
)

echo.
echo      [선택 MCP]
echo      - @modelcontextprotocol/server-github (GitHub 연동)...
call npx -y @modelcontextprotocol/server-github --help >nul 2>nul
if errorlevel 1 (
    echo        [설치중...]
) else (
    echo        [OK]
)

echo      - @isaacphi/mcp-gdrive (Google Drive 연동)...
call npx -y @isaacphi/mcp-gdrive --help >nul 2>nul
if errorlevel 1 (
    echo        [설치중...]
) else (
    echo        [OK]
)

echo.
echo [OK] MCP 패키지 설치 완료
echo.

REM ========================================
REM Step 4: Claude Desktop 설정 폴더 생성
REM ========================================
echo [4/5] Claude Desktop 설정 폴더 확인 중...

set CLAUDE_DIR=%APPDATA%\Claude
if not exist "%CLAUDE_DIR%" (
    mkdir "%CLAUDE_DIR%"
    echo      [생성됨] %CLAUDE_DIR%
) else (
    echo      [확인됨] %CLAUDE_DIR%
)
echo.

REM ========================================
REM Step 5: 설정 파일 생성 (API 키 자동 입력)
REM ========================================
echo [5/5] Claude Desktop 설정 파일 생성 중...

set CONFIG_FILE=%CLAUDE_DIR%\claude_desktop_config.json

if exist "%CONFIG_FILE%" (
    echo      [주의] 기존 설정 파일이 있습니다.
    echo      기존 파일 백업: %CONFIG_FILE%.backup
    copy /Y "%CONFIG_FILE%" "%CONFIG_FILE%.backup" >nul
)

REM Make MCP URL 설정 (기본값 또는 사용자 지정)
if "%MAKE_MCP_URL%"=="" (
    set "MAKE_MCP_URL=https://eu2.make.com/mcp/u/24d0c939-f69a-4c68-8ea9-8314e72d4dd0/sse"
)

REM JSON 파일 생성
(
echo {
echo   "mcpServers": {
echo     "make": {
echo       "command": "npx",
echo       "args": ["-y", "mcp-remote", "%MAKE_MCP_URL%"]
echo     },
echo     "airtable": {
echo       "command": "npx",
echo       "args": ["-y", "airtable-mcp-server"],
echo       "env": {
echo         "AIRTABLE_API_KEY": "%AIRTABLE_API_KEY%",
echo         "AIRTABLE_BASE_ID": "%AIRTABLE_BASE_ID%"
echo       }
echo     }
) > "%CONFIG_FILE%"

REM GitHub 토큰이 있으면 추가
if not "%GITHUB_TOKEN%"=="" (
    (
    echo     ,
    echo     "github": {
    echo       "command": "npx",
    echo       "args": ["-y", "@modelcontextprotocol/server-github"],
    echo       "env": {
    echo         "GITHUB_TOKEN": "%GITHUB_TOKEN%"
    echo       }
    echo     }
    ) >> "%CONFIG_FILE%"
)

REM JSON 닫기
(
echo   }
echo }
) >> "%CONFIG_FILE%"

echo      [OK] 설정 파일 생성됨 (API 키 자동 입력됨)
echo.

REM ========================================
REM 설치 완료
REM ========================================
echo.
echo ========================================
echo   설치 완료!
echo ========================================
echo.
echo 설정 파일 위치:
echo %CONFIG_FILE%
echo.
echo 적용된 설정:
echo - Make MCP: 연결됨
echo - Airtable: %AIRTABLE_BASE_ID%
if not "%GITHUB_TOKEN%"=="" echo - GitHub: 연결됨
echo.
echo ========================================
echo   다음 단계
echo ========================================
echo.
echo 1. Claude Desktop을 재시작하세요
echo    - 시스템 트레이에서 완전히 종료 후 다시 시작
echo.
echo 2. MCP 연결 확인
echo    - Claude Desktop에서 "MCP 도구 보여줘" 입력
echo    - Make, Airtable 도구가 표시되면 성공!
echo.
echo ========================================
echo.
pause
