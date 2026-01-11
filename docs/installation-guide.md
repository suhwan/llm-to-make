# LLM-to-Make 설치 가이드

> 비개발자를 위한 Step-by-Step 설치 가이드
>
> 예상 소요 시간: 10~15분

---

## 목차

1. [사전 준비: API 키 발급](#1-사전-준비-api-키-발급)
2. [자동 설치 실행](#2-자동-설치-실행)
3. [정상 설치 확인](#3-정상-설치-확인)
4. [Claude Desktop에서 연결 테스트](#4-claude-desktop에서-연결-테스트)
5. [문제 해결](#5-문제-해결)

---

## 1. 사전 준비: API 키 발급

설치 스크립트를 실행하기 전에 **3가지 API 키**를 먼저 준비하세요.

### 1-1. Make.com MCP URL (필수)

| 단계 | 설명 |
|------|------|
| 1 | [Make.com](https://www.make.com/) 로그인 |
| 2 | 좌측 메뉴 → **Organization** 클릭 |
| 3 | 상단 탭 → **MCP** 선택 |
| 4 | MCP URL 복사 |

**URL 형식:**
```
https://eu2.make.com/mcp/u/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/sse
```

> ⚠️ 이 URL은 비밀번호처럼 취급하세요!

---

### 1-2. Airtable API Key (필수)

| 단계 | 설명 |
|------|------|
| 1 | [Airtable 토큰 페이지](https://airtable.com/create/tokens) 접속 |
| 2 | **Create new token** 클릭 |
| 3 | Name: `llm-to-make` 입력 |
| 4 | Scopes 선택: `data.records:read`, `data.records:write`, `schema.bases:read` |
| 5 | Access: 사용할 Base 선택 |
| 6 | **Create token** 클릭 후 복사 |

**토큰 형식:**
```
pat.xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

---

### 1-3. Airtable Base ID (필수)

| 단계 | 설명 |
|------|------|
| 1 | [Airtable](https://airtable.com/) 접속 |
| 2 | 사용할 Base 열기 |
| 3 | URL에서 `app`로 시작하는 부분 복사 |

**URL 예시:**
```
https://airtable.com/appXXXXXXXXXXXXXX/tblYYYYYYY/...
                     ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
                     이 부분이 Base ID
```

---

### 준비물 체크리스트

설치 전 아래 3가지가 준비되었는지 확인하세요:

| 항목 | 예시 | 준비됨? |
|------|------|----------|
| Make MCP URL | `https://eu2.make.com/mcp/u/.../sse` | ☐ |
| Airtable API Key | `pat.xxxx...` | ☐ |
| Airtable Base ID | `appXXXXXXXXX` | ☐ |

> ✅ 3가지 모두 준비되었으면 다음 단계로!

---

## 2. 자동 설치 실행

### 2-1. 프로젝트 다운로드

**방법 A: Git 사용 (권장)**
```bash
git clone https://github.com/suhwan/llm-to-make.git
cd llm-to-make
```

**방법 B: ZIP 다운로드**
1. [GitHub 저장소](https://github.com/suhwan/llm-to-make) 접속
2. 녹색 **Code** 버튼 → **Download ZIP**
3. 압축 해제

---

### 2-2. 설치 스크립트 실행

#### Windows

1. `install` 폴더로 이동
2. `setup-mcp.bat` 더블클릭 (또는 명령 프롬프트에서 실행)

```cmd
cd install
setup-mcp.bat
```

#### Mac / Linux

```bash
cd install
chmod +x setup-mcp.sh
./setup-mcp.sh
```

---

### 2-3. 설치 과정 안내

스크립트가 자동으로 **5단계**를 수행합니다:

```
========================================
  LLM-to-Make MCP Setup Script
========================================

[1/5] Checking Node.js...        ← Node.js 설치 확인
      [OK] Node.js found: v20.10.0

[2/5] Checking .env file...      ← API 키 설정 확인
      [INFO] .env file not found.
      Opening in Notepad...      ← 메모장이 열림, API 키 입력

[3/5] Checking MCP configuration...  ← MCP 서버 선택
      [Required]
        1. [x] Make.com
        2. [x] Airtable
      [Optional]
        3. [ ] GitHub
        4. [ ] Google Drive
        5. [ ] Playwright

[4/5] Installing packages...     ← NPM 패키지 자동 설치
      - mcp-remote... [OK]
      - airtable-mcp-server... [OK]

[5/5] Generating .mcp.json...    ← 설정 파일 생성
      [OK] .mcp.json created

========================================
  Setup Complete!
========================================
```

---

### 2-4. API 키 입력 (Step 2에서)

메모장(또는 텍스트 에디터)이 열리면 준비한 API 키를 입력합니다:

```env
# [필수] Make.com MCP URL
MAKE_MCP_URL=https://eu2.make.com/mcp/u/your-uuid-here/sse

# [필수] Airtable 설정
AIRTABLE_API_KEY=pat.your-token-here
AIRTABLE_BASE_ID=appYourBaseId

# [선택] GitHub 설정
GITHUB_TOKEN=
```

> ⚠️ 등호(=) 앞뒤에 공백 없이 입력!

저장 후 메모장을 닫고, 스크립트를 다시 실행하세요.

---

## 3. 정상 설치 확인

설치가 완료되면 아래 항목들을 확인하세요.

### 3-1. 파일 확인

프로젝트 루트 폴더에서 확인:

| 파일 | 위치 | 확인 방법 |
|------|------|------------|
| `.mcp.json` | 프로젝트 루트 | 파일이 존재하면 OK |
| `.env` | install/ 폴더 | API 키가 입력되어 있으면 OK |

**확인 명령어:**
```bash
# 프로젝트 루트로 이동
cd llm-to-make

# .mcp.json 확인
cat .mcp.json
```

**정상 출력:**
```json
{
  "mcpServers": {
    "make": {
      "command": "node",
      "args": ["install/make-mcp-wrapper.js"]
    },
    "airtable": {
      "command": "npx",
      "args": ["-y", "dotenv-cli", "-e", ".env", "--", "npx", "-y", "airtable-mcp-server"]
    }
  }
}
```

---

### 3-2. Node.js 확인

```bash
node --version
```

**정상 출력:** `v20.x.x` 또는 그 이상

---

### 3-3. 설치 체크리스트

| # | 항목 | 확인 방법 | 결과 |
|---|------|-----------|------|
| 1 | Node.js 설치됨 | `node --version` | ☐ v20.x.x |
| 2 | .env 파일 존재 | `install/.env` 파일 확인 | ☐ 존재함 |
| 3 | API 키 입력됨 | .env에서 `MAKE_MCP_URL=https://...` 확인 | ☐ 입력됨 |
| 4 | .mcp.json 생성됨 | 프로젝트 루트에 파일 존재 | ☐ 존재함 |
| 5 | MCP 서버 설정됨 | .mcp.json에 `make`, `airtable` 포함 | ☐ 포함됨 |

> ✅ 5개 모두 체크되면 설치 완료!

---

## 4. Claude Desktop에서 연결 테스트

### 4-1. Claude Desktop 실행

1. **Claude Desktop** 앱 실행
2. 프로젝트 폴더 열기 (`llm-to-make` 폴더)

또는 터미널에서:
```bash
cd llm-to-make
claude
```

---

### 4-2. Make.com 연결 테스트

Claude Desktop에서 다음을 입력:

```
Make 조직 목록 보여줘
```

**정상 응답 예시:**
```
📋 Make.com 조직 목록

| ID | 이름 |
|----|------|
| 12345 | My Organization |
```

**오류 시:**
- `MAKE_MCP_URL not set` → `.env` 파일에서 URL 확인
- `연결 실패` → URL 형식이 올바른지 확인

---

### 4-3. Airtable 연결 테스트

Claude Desktop에서 다음을 입력:

```
Airtable 테이블 목록 보여줘
```

**정상 응답 예시:**
```
📊 Airtable 테이블 (5개)

| 테이블명 | 레코드 수 |
|----------|------------|
| Models | 12 |
| Content_Requests | 45 |
| Generated_Contents | 128 |
```

**오류 시:**
- `인증 실패` → `AIRTABLE_API_KEY` 확인
- `Base not found` → `AIRTABLE_BASE_ID` 확인

---

### 4-4. 전체 연결 테스트

Claude Desktop에서 `/status` 명령 실행:

```
/status
```

**정상 응답 예시:**
```
📊 프로젝트 현황

✅ MCP 연결 상태:
- Make: 연결됨
- Airtable: 연결됨

🎬 시나리오: 2개
📊 테이블: 5개
```

> ✅ Make와 Airtable 모두 "연결됨"이면 성공!

---

## 5. 문제 해결

### Q1: "Node.js is not installed" 오류

**원인:** Node.js가 설치되지 않음

**해결:**
1. [nodejs.org](https://nodejs.org/) 접속
2. LTS 버전 다운로드 및 설치
3. 컴퓨터 재시작
4. 스크립트 다시 실행

---

### Q2: .env 파일에 API 키를 입력했는데 오류

**확인 사항:**
```env
# 올바른 형식 (공백 없음)
MAKE_MCP_URL=https://eu2.make.com/mcp/u/xxx/sse

# 잘못된 형식 (공백 있음)
MAKE_MCP_URL = https://eu2.make.com/mcp/u/xxx/sse
```

> 등호(=) 앞뒤에 공백이 있으면 안 됩니다!

---

### Q3: Claude Desktop에서 MCP가 로드되지 않음

**확인 사항:**
1. `.mcp.json` 파일이 프로젝트 **루트**에 있는지 확인
2. Claude Desktop을 **프로젝트 폴더에서** 열었는지 확인

**올바른 실행:**
```bash
cd llm-to-make    # 프로젝트 폴더로 이동
claude            # 여기서 실행
```

---

### Q4: "MAKE_MCP_URL not set" 오류

**원인:** `.env` 파일 위치가 잘못됨

**확인:**
- `.env` 파일은 `install/` 폴더 안에 있어야 합니다
- 경로: `llm-to-make/install/.env`

---

### Q5: Airtable 연결은 되는데 Make 연결 실패

**확인:**
1. Make MCP URL이 올바른지 확인
2. URL이 `/sse`로 끝나는지 확인
3. Make.com에서 MCP가 활성화되어 있는지 확인

---

## 다음 단계

설치가 완료되었습니다! 이제 다음을 시도해보세요:

| 명령어 | 설명 |
|--------|------|
| `/status` | 현재 프로젝트 상태 확인 |
| `/check-tables` | Airtable 테이블 구조 확인 |
| `/new-scenario` | 새 자동화 시나리오 생성 |
| `/backup` | 기존 시나리오 백업 |

**예시 대화:**
```
나: "인스타그램에 자동으로 포스팅하는 시나리오 만들어줘"

Claude: "네, SNS 자동 포스팅 시나리오를 만들겠습니다.
         먼저 사용할 테이블과 트리거 조건을 확인할게요..."
```

---

## 도움이 필요하면

- [GitHub Issues](https://github.com/suhwan/llm-to-make/issues)에 문의
- 에러 메시지와 함께 OS, Node.js 버전을 첨부해주세요
