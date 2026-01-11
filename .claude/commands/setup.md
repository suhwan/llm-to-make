# /setup - 온보딩 프로세스

이 스킬은 첫 사용자를 위한 순차적 온보딩을 수행합니다.

---

## 사용하는 MCP 도구

| 단계 | MCP 도구 | 용도 |
|------|----------|------|
| Step 2 | `Read` | .env 파일 확인 |
| Step 4 | `mcp__make__organizations_list` | Make 연결 테스트 |
| Step 4 | `mcp__airtable__list_tables` | Airtable 연결 테스트 |
| Step 5 | `AskUserQuestion` | 용도 선택 |
| Step 6.1 | `AskUserQuestion` | Base 선택 |
| Step 6.2 | `mcp__airtable__list_tables` | 테이블 목록 조회 |
| Step 6.2 | `mcp__airtable__describe_table` | 테이블 상세 구조 |
| Step 6.3 | `mcp__make__scenarios_list` | 시나리오 목록 조회 |
| Step 6.3 | `mcp__make__scenarios_get` | 시나리오 상세 (청사진) |
| Step 6.3 | `mcp__make__connections_list` | 연결 목록 조회 |
| Step 7.2 | `Bash` | 디렉터리 생성 |
| Step 7.3 | `Write` | plan.md 파일 생성 |

---

## 실행 지침

### Step 1: 환영 및 소개
사용자에게 다음 메시지를 표시합니다:

```
🚀 LLM-to-Make 프로젝트에 오신 것을 환영합니다!

이 도구를 사용하면 자연어로 Make.com 자동화 시나리오를 만들 수 있습니다.
코딩 지식 없이도 복잡한 자동화를 구축할 수 있습니다.

지금부터 환경 설정을 확인하겠습니다.
```

---

### Step 2: .env 파일 확인
`.env` 파일이 존재하는지 확인합니다.

**확인 방법**:
```
Read 도구로 /home/ubuntu/code/llm-to-make/.env 파일 읽기 시도
```

**결과에 따른 분기**:
- 파일 있음 → Step 3으로 진행
- 파일 없음 → 안내:
  ```
  ⚠️ .env 파일이 없습니다.

  .env.example 파일을 .env로 복사하고 API 키를 입력해주세요:

  cp .env.example .env

  설정 완료 후 다시 /setup을 실행해주세요.
  ```

---

### Step 3: 필수 API 키 확인
.env 파일에서 필수 환경변수를 확인합니다.

**확인할 변수**:
1. `MAKE_MCP_TOKEN` - Make.com API 토큰
2. `AIRTABLE_API_KEY` - Airtable API 키
3. `AIRTABLE_BASE_ID` - Airtable Base ID

**각 변수별 처리**:
- 값 있음 → ✅ 표시
- 값 없음 → ❌ 표시 + 발급 방법 안내

**출력 예시**:
```
📋 환경변수 확인 중...

✅ MAKE_MCP_TOKEN: 설정됨
✅ AIRTABLE_API_KEY: 설정됨
✅ AIRTABLE_BASE_ID: appzQEgOxUpCYGmk7

❌ GITHUB_TOKEN: 미설정 (선택)
❌ GDRIVE_FOLDER_ID: 미설정 (선택)
```

필수 변수 중 하나라도 없으면 docs/onboarding.md의 발급 방법을 안내하고 대기합니다.

---

### Step 4: MCP 연결 테스트
각 MCP 플러그인이 정상 작동하는지 테스트합니다.

**Make MCP 테스트**:
```
mcp__make__organizations_list 호출
```
- 성공 → 조직 목록 표시
- 실패 → MAKE_MCP_TOKEN 확인 안내

**Airtable MCP 테스트**:
```
mcp__airtable__list_tables (baseId: AIRTABLE_BASE_ID 사용)
```
- 성공 → 테이블 목록 표시
- 실패 → AIRTABLE_API_KEY 확인 안내

---

### Step 5: 용도 확인
AskUserQuestion 도구를 사용하여 사용 목적을 질문합니다.

```yaml
question: "무엇을 하시겠습니까?"
header: "작업 선택"
options:
  - label: "새 프로젝트 시작"
    description: "처음부터 새로운 자동화 시나리오를 만듭니다"
  - label: "기존 프로젝트 수정"
    description: "이미 있는 시나리오를 수정하거나 개선합니다"
  - label: "프로젝트 분석"
    description: "현재 Airtable/Make 구조를 분석하고 문서화합니다"
```

**"새 프로젝트 시작" 선택 시** → 추가 질문:
```yaml
question: "어떤 자동화를 만들고 싶으세요?"
header: "시나리오 유형"
options:
  - label: "이미지/영상 생성"
    description: "AI로 이미지나 영상을 자동 생성"
  - label: "데이터 동기화"
    description: "Airtable ↔ Google Sheets 등 연동"
  - label: "SNS 자동화"
    description: "Instagram, Threads 자동 포스팅"
```

**"기존 프로젝트 수정" 선택 시** → Step 6으로 진행 (시나리오 목록 표시)

**"프로젝트 분석" 선택 시** → Step 6으로 진행 (전체 분석)

---

### Step 6: Airtable Base 선택 및 분석

#### 6.1 Base 선택
```yaml
question: "어떤 Airtable Base를 사용하시겠습니까?"
header: "Base 선택"
options:
  - label: "기존 Base 사용"
    description: ".env에 설정된 Base (appzQEgOxUpCYGmk7)"
  - label: "다른 Base 입력"
    description: "새로운 Base ID를 직접 입력합니다"
```

**"다른 Base 입력" 선택 시**:
- 사용자에게 Base ID 입력 요청
- 입력받은 ID로 접근 테스트 (list_tables)
- 성공 시 → 분석 진행
- 실패 시 → 오류 안내 및 재입력 요청

#### 6.2 Airtable 구조 분석
`list_tables` + `describe_table`로 전체 구조 분석:

```
📊 Airtable Base 분석 결과

🗂️ 테이블 구조:
┌─────────────────────────────────────────────────────────┐
│ Models (tblOfVAOxlY29TBjH)                              │
│ └─ 용도: AI 모델 정보 관리                                │
│ └─ 주요 필드: Name, Main_Image, Status                   │
│ └─ 연결: Content_Requests, Model_Personas, SNS_Posts     │
├─────────────────────────────────────────────────────────┤
│ Content_Requests (tblImBDg1HTY6sSsP)                    │
│ └─ 용도: 콘텐츠 생성 요청 접수                            │
│ └─ 주요 필드: Model_ID, Scene_Image, Status              │
│ └─ 연결: Models ← | → Generated_Contents                │
├─────────────────────────────────────────────────────────┤
│ Generated_Contents (tblYEykfAmWSrtcP8)                  │
│ └─ 용도: 생성된 이미지 저장                               │
│ └─ 연결: Content_Requests ← | → Generated_Video_Contents│
└─────────────────────────────────────────────────────────┘

🔗 테이블 관계도:
Models → Content_Requests → Generated_Contents → Generated_Video_Contents
   ↓
Model_Personas, SNS_Posts
```

#### 6.3 Make 시나리오 분석
`scenarios_list` + `scenarios_get`으로 시나리오별 Airtable 사용 현황 분석:

```
🎬 Make 시나리오 분석

┌─────────────────────────────────────────────────────────┐
│ 시나리오: suhwan-image-to-video-v1 (ID: 8436833)        │
│ └─ 상태: 활성화                                          │
│ └─ 트리거: Airtable Watch (Generated_Contents)          │
│                                                          │
│ 📋 사용하는 테이블:                                       │
│    ├─ Generated_Contents (읽기/쓰기)                     │
│    │   └─ 모듈 1: Watch - 새 레코드 감지                  │
│    │   └─ 모듈 12: Update - 상태 업데이트                 │
│    │                                                     │
│    └─ Generated_Video_Contents (쓰기)                    │
│        └─ 모듈 3: Create - 영상 레코드 생성               │
│        └─ 모듈 18: Update - 완료 상태 저장                │
│                                                          │
│ 🔧 사용하는 연결:                                         │
│    ├─ Airtable OAuth (12046948)                         │
│    ├─ Google Drive (12046957)                           │
│    └─ Runware.AI (13479550)                             │
└─────────────────────────────────────────────────────────┘
```

#### 6.4 분석 결과 확인
```yaml
question: "분석 결과가 맞습니까?"
header: "확인"
options:
  - label: "네, 맞습니다"
    description: "다음 단계로 진행합니다"
  - label: "다시 분석"
    description: "다른 Base나 시나리오를 분석합니다"
```

---

### Step 7: 프로젝트 디렉터리 생성

#### 7.1 프로젝트 이름 입력
```yaml
question: "프로젝트 이름을 입력해주세요"
header: "프로젝트명"
# 사용자가 직접 입력 (예: "image-to-video", "sns-automation")
```

#### 7.2 디렉터리 생성
```
projects/{프로젝트명}/
├── plan.md           # 이 프로젝트의 계획 및 상태
├── blueprints/       # 시나리오 청사진 백업
└── docs/             # 프로젝트별 문서
```

**Bash 명령어**:
```bash
mkdir -p projects/{프로젝트명}/blueprints
mkdir -p projects/{프로젝트명}/docs
```

#### 7.3 프로젝트 plan.md 생성
Write 도구로 `projects/{프로젝트명}/plan.md` 파일 생성:

```markdown
# {프로젝트명} 프로젝트 계획

> **생성일**: {현재 날짜}
> **상태**: 🚀 시작됨
> **Base**: {선택한 Airtable Base ID}

---

## 프로젝트 개요

{사용자가 선택한 용도에 따른 설명}

---

## 사용 리소스

### Airtable 테이블
{Step 6에서 분석한 테이블 목록}

### Make 연결
{Step 6에서 확인한 연결 목록}

### 관련 시나리오
{Step 6에서 분석한 시나리오 목록}

---

## Tasks

### Task 1: {첫 번째 작업}
> **상태**: ⏳ 대기

- [ ] 세부 작업 1
- [ ] 세부 작업 2

---

## 변경 이력

| 날짜 | 버전 | 변경 내용 |
|------|------|----------|
| {현재 날짜} | v0.1.0 | 프로젝트 생성 |
```

---

### Step 8: 완료 및 다음 단계 안내

```
✅ 프로젝트 설정이 완료되었습니다!

📁 생성된 프로젝트:
   projects/{프로젝트명}/
   ├── plan.md       ← 여기에 진행 상황이 기록됩니다
   ├── blueprints/   ← 시나리오 백업
   └── docs/         ← 프로젝트 문서

---

🚀 다음 단계:

1. 프로젝트 계획 확인:
   "projects/{프로젝트명}/plan.md 보여줘"

2. 시나리오 생성 시작:
   "이미지를 영상으로 변환하는 시나리오 만들어줘"

3. 테이블 수정:
   "Generated_Contents에 새 필드 추가해줘"

---

💡 명령어:
- /new-scenario : 새 시나리오 생성
- /check-tables : Airtable 스키마 확인
- /status       : 프로젝트 진행 상황

📚 문서:
- docs/scenario-templates.md : 시나리오 템플릿
- docs/table-schema.md       : 테이블 스키마
```

---

## 주의사항

1. **순차적 진행**: 각 단계를 건너뛰지 않고 순서대로 진행
2. **사용자 확인**: 중요 단계마다 사용자 응답 대기
3. **에러 처리**: 문제 발생 시 명확한 해결 방법 안내
4. **문서 참조**: 상세 내용은 docs/onboarding.md로 안내
5. **프로젝트별 관리**: 각 프로젝트는 별도 디렉터리에서 plan.md로 추적
