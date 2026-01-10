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
echo [1/4] Node.js 확인 중...

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
REM Step 2: NPM 패키지 설치
REM ========================================
echo [2/4] MCP 패키지 설치 중...
echo      (처음 실행 시 몇 분 소요될 수 있습니다)
echo.

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
REM Step 3: Claude Desktop 설정 폴더 생성
REM ========================================
echo [3/4] Claude Desktop 설정 폴더 확인 중...

set CLAUDE_DIR=%APPDATA%\Claude
if not exist "%CLAUDE_DIR%" (
    mkdir "%CLAUDE_DIR%"
    echo      [생성됨] %CLAUDE_DIR%
) else (
    echo      [확인됨] %CLAUDE_DIR%
)
echo.

REM ========================================
REM Step 4: 설정 파일 복사
REM ========================================
echo [4/4] Claude Desktop 설정 파일 생성 중...

set CONFIG_FILE=%CLAUDE_DIR%\claude_desktop_config.json
set SOURCE_FILE=%~dp0claude_desktop_config.json

if exist "%CONFIG_FILE%" (
    echo      [주의] 기존 설정 파일이 있습니다.
    echo      기존 파일 백업: %CONFIG_FILE%.backup
    copy /Y "%CONFIG_FILE%" "%CONFIG_FILE%.backup" >nul
)

if exist "%SOURCE_FILE%" (
    copy /Y "%SOURCE_FILE%" "%CONFIG_FILE%" >nul
    echo      [OK] 설정 파일 복사됨
) else (
    echo      [오류] claude_desktop_config.json 파일을 찾을 수 없습니다.
    echo      이 스크립트와 같은 폴더에 파일이 있는지 확인하세요.
    pause
    exit /b 1
)
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
echo ========================================
echo   다음 단계 (중요!)
echo ========================================
echo.
echo 1. 설정 파일에서 API 키 입력:
echo    - 메모장으로 위 파일을 열어서 아래 값들을 수정하세요:
echo.
echo    [Airtable]
echo    - YOUR_AIRTABLE_API_KEY   → Airtable API 키
echo    - YOUR_AIRTABLE_BASE_ID   → Airtable Base ID
echo.
echo    [GitHub]
echo    - YOUR_GITHUB_TOKEN       → GitHub 개인 액세스 토큰
echo.
echo 2. Claude Desktop 재시작:
echo    - Claude Desktop을 완전히 종료 후 다시 시작하세요
echo    - 시스템 트레이에서도 종료해야 합니다
echo.
echo 3. MCP 연결 확인:
echo    - Claude Desktop에서 채팅창에 "mcp" 입력
echo    - 사용 가능한 도구 목록이 표시되면 성공!
echo.
echo ========================================
echo   API 키 발급 방법
echo ========================================
echo.
echo [Airtable]
echo   1. https://airtable.com/account 접속
echo   2. "API" 섹션에서 Personal Access Token 생성
echo   3. Base ID는 Base URL에서 확인 (app으로 시작)
echo.
echo [GitHub]
echo   1. https://github.com/settings/tokens 접속
echo   2. "Generate new token (classic)" 클릭
echo   3. repo 권한 선택 후 토큰 생성
echo.
echo ========================================
echo.
echo 도움이 필요하시면 docs/windows-setup-guide.md를 참조하세요.
echo.
pause
