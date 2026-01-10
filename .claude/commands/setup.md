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
