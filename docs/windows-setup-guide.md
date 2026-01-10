# Windows 설치 가이드

> **대상**: Windows 사용자 (비개발자)
> **소요 시간**: 약 15-20분
> **난이도**: 쉬움

---

## 목차

1. [사전 요구사항](#1-사전-요구사항)
2. [Node.js 설치](#2-nodejs-설치)
3. [Claude Desktop 설치](#3-claude-desktop-설치)
4. [MCP 자동 설치](#4-mcp-자동-설치)
5. [API 키 설정](#5-api-키-설정)
6. [설치 확인](#6-설치-확인)
7. [문제 해결](#7-문제-해결)

---

## 1. 사전 요구사항

설치를 시작하기 전에 다음을 준비하세요:

| 항목 | 필수 여부 | 설명 |
|------|-----------|------|
| Windows 10/11 | 필수 | 64비트 운영체제 |
| 인터넷 연결 | 필수 | 설치 파일 다운로드용 |
| Anthropic 계정 | 필수 | Claude Desktop 사용 |
| Airtable 계정 | 선택 | Airtable 연동 시 필요 |
| GitHub 계정 | 선택 | GitHub 연동 시 필요 |

---

## 2. Node.js 설치

MCP 서버를 실행하려면 Node.js가 필요합니다.

### 설치 단계

1. **Node.js 공식 사이트 접속**
   - 웹 브라우저에서 https://nodejs.org/ 접속

2. **LTS 버전 다운로드**
   - 초록색 "LTS" 버튼 클릭 (권장 버전)
   - `node-vXX.XX.X-x64.msi` 파일 다운로드됨

3. **설치 프로그램 실행**
   - 다운로드된 `.msi` 파일 더블클릭
   - "Next" 버튼을 계속 클릭하여 설치
   - 기본 설정 그대로 사용 권장

4. **설치 확인**
   - `Windows 키 + R` 누르기
   - `cmd` 입력 후 Enter
   - 명령 프롬프트에서 `node --version` 입력
   - `v20.x.x` 같은 버전 번호가 표시되면 성공

### 직접 다운로드 링크

- **Node.js 20 LTS (권장)**: https://nodejs.org/dist/v20.11.0/node-v20.11.0-x64.msi

---

## 3. Claude Desktop 설치

### 설치 단계

1. **Claude Desktop 다운로드**
   - https://claude.ai/download 접속
   - "Download for Windows" 클릭

2. **설치 프로그램 실행**
   - 다운로드된 `Claude-Setup-x.x.x.exe` 실행
   - 설치 마법사 지시 따르기

3. **로그인**
   - Claude Desktop 실행
   - Anthropic 계정으로 로그인

---

## 4. MCP 자동 설치

### 방법 1: 자동 설치 스크립트 (권장)

1. **이 저장소 다운로드**
   - https://github.com/suhwan/llm-to-make 접속
   - 초록색 "Code" 버튼 → "Download ZIP"
   - 다운로드된 ZIP 파일 압축 해제

2. **설치 스크립트 실행**
   - 압축 해제된 폴더에서 `install` 폴더 열기
   - `setup-mcp.bat` 더블클릭

3. **화면 지시 따르기**
   - 스크립트가 자동으로:
     - Node.js 설치 확인
     - MCP 패키지 설치
     - Claude Desktop 설정 파일 생성

### 방법 2: 수동 설정

자동 설치가 작동하지 않을 경우:

1. **설정 파일 위치 찾기**
   - `Windows 키 + R` 누르기
   - `%APPDATA%\Claude` 입력 후 Enter
   - 이 폴더가 없으면 새로 만들기

2. **설정 파일 복사**
   - `install/claude_desktop_config.json` 파일을
   - 위 폴더에 복사

---

## 5. API 키 설정

설치 후 API 키를 설정해야 MCP가 작동합니다.

### Airtable API 키 발급

1. **Airtable 설정 접속**
   - https://airtable.com/account 로그인

2. **Personal Access Token 생성**
   - 왼쪽 메뉴에서 "Developer hub" 클릭
   - "Create new token" 클릭
   - 이름 입력 (예: "Claude MCP")
   - Scopes에서 필요한 권한 선택:
     - `data.records:read`
     - `data.records:write`
     - `schema.bases:read`
     - `schema.bases:write`
   - "Create token" 클릭
   - 생성된 토큰 복사 (한 번만 표시됨!)

3. **Base ID 확인**
   - Airtable에서 사용할 Base 열기
   - URL에서 `app`으로 시작하는 부분이 Base ID
   - 예: `https://airtable.com/appXXXXXXXXXX/...`
   - `appXXXXXXXXXX`가 Base ID

### GitHub 토큰 발급

1. **GitHub 설정 접속**
   - https://github.com/settings/tokens 로그인

2. **Personal Access Token 생성**
   - "Generate new token (classic)" 클릭
   - Note: "Claude MCP" 입력
   - Expiration: 원하는 기간 선택
   - Scopes 선택:
     - `repo` (전체 선택)
   - "Generate token" 클릭
   - 생성된 토큰 복사

### 설정 파일에 키 입력

1. **설정 파일 열기**
   - `Windows 키 + R`
   - `notepad %APPDATA%\Claude\claude_desktop_config.json` 입력 후 Enter

2. **API 키 입력**
   ```json
   {
     "mcpServers": {
       "airtable": {
         "env": {
           "AIRTABLE_API_KEY": "pat여기에_복사한_토큰_붙여넣기",
           "AIRTABLE_BASE_ID": "appXXXXXXXXXX"
         }
       },
       "github": {
         "env": {
           "GITHUB_TOKEN": "ghp_여기에_복사한_토큰_붙여넣기"
         }
       }
     }
   }
   ```

3. **파일 저장**
   - `Ctrl + S`로 저장

---

## 6. 설치 확인

### Claude Desktop 재시작

1. **시스템 트레이에서 종료**
   - 화면 오른쪽 하단 시스템 트레이에서
   - Claude 아이콘 우클릭 → "Quit" 또는 "종료"

2. **다시 시작**
   - Claude Desktop 다시 실행

### MCP 연결 확인

1. **Claude Desktop에서 테스트**
   - 채팅창에 다음 입력:
   ```
   현재 사용 가능한 MCP 도구를 보여줘
   ```

2. **성공 시**
   - Make, Airtable, GitHub 관련 도구 목록이 표시됨

3. **실패 시**
   - [문제 해결](#7-문제-해결) 섹션 참조

---

## 7. 문제 해결

### "Node.js를 찾을 수 없습니다"

**원인**: Node.js가 설치되지 않았거나, 설치 후 재시작하지 않음

**해결**:
1. Node.js 설치 (섹션 2 참조)
2. 컴퓨터 재시작
3. 스크립트 다시 실행

### "MCP 서버가 연결되지 않습니다"

**원인**: 설정 파일 오류 또는 Claude Desktop 미재시작

**해결**:
1. 설정 파일이 올바른 위치에 있는지 확인
   - `%APPDATA%\Claude\claude_desktop_config.json`
2. JSON 문법 오류 확인
   - https://jsonlint.com/ 에서 검증
3. Claude Desktop 완전히 종료 후 재시작

### "API 키가 잘못되었습니다"

**원인**: API 키 복사 오류 또는 만료

**해결**:
1. API 키가 정확히 복사되었는지 확인
   - 앞뒤 공백 없이
   - 따옴표 안에 정확히 입력
2. 토큰이 만료되지 않았는지 확인
3. 새 토큰 발급 후 다시 시도

### "JSON 파싱 오류"

**원인**: 설정 파일의 JSON 문법 오류

**해결**:
1. 쉼표(,)가 올바른 위치에 있는지 확인
2. 따옴표(")가 제대로 닫혔는지 확인
3. `install/claude_desktop_config.json`을 다시 복사

### 로그 확인 방법

1. **Claude Desktop 로그 위치**
   - `%APPDATA%\Claude\logs`

2. **MCP 서버 로그**
   - Claude Desktop 설정에서 개발자 모드 활성화
   - 로그에서 에러 메시지 확인

---

## 추가 리소스

- **Claude Desktop 공식 문서**: https://docs.anthropic.com/claude/docs/claude-for-desktop
- **MCP 공식 문서**: https://modelcontextprotocol.io/
- **이 프로젝트 GitHub**: https://github.com/suhwan/llm-to-make

---

## 업데이트 이력

| 날짜 | 버전 | 변경 사항 |
|------|------|----------|
| 2026-01-10 | v1.0.0 | 초기 문서 작성 |
