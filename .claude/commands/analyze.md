# /analyze - 기존 시나리오 분석

이 스킬은 기존 Make 시나리오를 분석하여 구조와 흐름을 파악합니다.

---

## 사용하는 MCP 도구

| 단계 | MCP 도구 | 용도 |
|------|----------|------|
| Step 1 | `mcp__make__scenarios_list` | 시나리오 목록 조회 |
| Step 2 | `AskUserQuestion` | 분석할 시나리오 선택 |
| Step 3 | `mcp__make__scenarios_get` | 시나리오 상세 + 청사진 |

---

## 실행 지침

### Step 1: 시나리오 목록 조회

**mcp__make__scenarios_list 호출**:
```
teamId: 2759651
```

**출력**:
```
🎬 Make 시나리오 목록

| # | 이름 | ID | 상태 |
|---|------|-----|------|
| 1 | image-to-video | 8436833 | ✅ 활성 |
| 2 | sns-posting | 8437001 | ⏸️ 비활성 |
```

---

### Step 2: 시나리오 선택

```yaml
question: "어떤 시나리오를 분석할까요?"
header: "시나리오"
options:
  - label: "image-to-video"
    description: "ID: 8436833"
  - label: "sns-posting"
    description: "ID: 8437001"
```

---

### Step 3: 분석 결과 출력

**mcp__make__scenarios_get 호출 후 출력**:

```
📋 시나리오 분석: image-to-video

기본 정보:
- ID: 8436833
- 상태: ✅ 활성
- 스케줄: 15분마다

모듈 흐름:
[1] Airtable Watch → [2] Search → [3] Create
    ↓
[4] Router
    ├─→ [5-8] Runway 경로
    └─→ [9-12] Runware 경로

사용된 연결:
- Airtable OAuth (12046948)
- Google Drive (12046957)
- Runware.AI (13479550)

사용된 테이블:
- Generated_Contents
- Generated_Video_Contents
```

---

### Step 4: 다음 작업

```yaml
question: "추가로 무엇을 할까요?"
header: "다음"
options:
  - label: "청사진 백업"
    description: "blueprints/에 저장"
  - label: "다른 시나리오 분석"
    description: "다른 시나리오 선택"
  - label: "종료"
    description: "분석 마침"
```
