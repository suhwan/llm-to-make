# LLM-to-Make

> 비개발자가 자연어로 Make.com 자동화 시나리오를 만들 수 있도록 지원하는 프로젝트

---

## 빠른 시작 (5분)

### 1. 프로젝트 다운로드

```bash
git clone https://github.com/suhwan/llm-to-make.git
cd llm-to-make
```

### 2. 환경 설정

```bash
cd install
cp .env.template .env
```

`.env` 파일을 열고 API 키 입력:

```env
MAKE_MCP_URL=https://eu2.make.com/mcp/u/your-uuid/sse
AIRTABLE_API_KEY=pat.your-token
AIRTABLE_BASE_ID=appYourBaseId
```

### 3. MCP 서버 설치

```bash
# Windows
setup-mcp.bat

# Mac/Linux
chmod +x setup-mcp.sh
./setup-mcp.sh
```

### 4. 설치 확인

```bash
cd ..
cat .mcp.json  # 설정 파일 확인
```

> 자세한 설치 가이드: [docs/installation-guide.md](docs/installation-guide.md)

---

## 사용 가능한 스킬

| 스킬 | 용도 | 설명 |
|------|------|------|
| `/setup` | 온보딩 | 프로젝트 초기 설정 |
| `/new-scenario` | 시나리오 생성 | 자연어로 Make 시나리오 생성 |
| `/check-tables` | 테이블 확인 | Airtable 스키마 분석 |
| `/status` | 현황 확인 | 프로젝트 진행 상태 |
| `/analyze` | 시나리오 분석 | 기존 시나리오 구조 파악 |
| `/backup` | 청사진 백업 | 시나리오를 JSON으로 저장 |

---

## 설치 확인 체크리스트

| 항목 | 확인 명령 | 정상 결과 |
|------|-----------|-----------|
| Node.js | `node --version` | `v20.x.x` |
| .env 파일 | `cat install/.env` | API 키 설정됨 |
| .mcp.json | `cat .mcp.json` | MCP 서버 설정됨 |
| Make 연결 | Claude Code에서 `/status` | 연결됨 표시 |

---

## 프로젝트 구조

```
llm-to-make/
├── .claude/
│   └── commands/      # 스킬 정의 파일
├── blueprints/        # 시나리오 청사진 템플릿
├── docs/              # 문서
│   ├── installation-guide.md  # 설치 가이드
│   ├── onboarding.md          # 온보딩 가이드
│   └── scenario-templates.md  # 시나리오 예제
├── install/           # 설치 스크립트
│   ├── setup-mcp.sh   # Linux/Mac 설치
│   ├── setup-mcp.bat  # Windows 설치
│   ├── .env.template  # 환경변수 템플릿
│   └── make-mcp-wrapper.js  # Make MCP 래퍼
└── .mcp.json          # MCP 서버 설정 (설치 후 생성)
```

---

## 필요한 API 키

| 서비스 | 발급 링크 | 필수 여부 |
|--------|-----------|-----------|
| Make.com MCP URL | [Organization Settings > MCP](https://www.make.com/) | 필수 |
| Airtable API Key | [airtable.com/create/tokens](https://airtable.com/create/tokens) | 필수 |
| GitHub Token | [github.com/settings/tokens](https://github.com/settings/tokens) | 선택 |

---

## 문서

- [설치 가이드](docs/installation-guide.md) - 단계별 설치 방법
- [온보딩 가이드](docs/onboarding.md) - 처음 사용자를 위한 안내
- [시나리오 템플릿](docs/scenario-templates.md) - 시나리오 예제
- [테이블 스키마](docs/table-schema.md) - Airtable 구조

---

## 문제 해결

### Node.js 설치 안 됨
```bash
# Mac
brew install node

# Ubuntu
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### MAKE_MCP_URL 오류
`.env` 파일에서 URL 형식 확인:
```
MAKE_MCP_URL=https://eu2.make.com/mcp/u/YOUR-UUID/sse
```

### 권한 오류 (Linux/Mac)
```bash
chmod +x install/setup-mcp.sh
```

> 더 많은 문제 해결: [docs/installation-guide.md#문제-해결](docs/installation-guide.md#문제-해결)

---

## 라이선스

MIT
