# /new-scenario - 자연어 기반 시나리오 생성

이 스킬은 `/setup` 완료 후 실행되며, **자연어 설명을 바탕으로** Make 시나리오를 생성합니다.

> **핵심 원칙**: 템플릿에 의존하지 않고, 사용자 설명 → Make 모듈 직접 조합

---

## 사용하는 MCP 도구

| 단계 | MCP 도구 | 용도 |
|------|----------|------|
| Step 0 | `Glob` | /setup 완료 확인 (projects/*/plan.md) |
| Step 1 | `AskUserQuestion` | 프로젝트 선택 |
| Step 2 | (텍스트 입력) | 자연어로 시나리오 설명 |
| Step 3 | `mcp__airtable__describe_table` | 관련 테이블 분석 |
| Step 3 | `mcp__make__connections_list` | 사용 가능한 연결 확인 |
| Step 4 | `mcp__make__apps_recommend` | 필요한 앱/모듈 추천 |
| Step 4 | `mcp__make__app-module_get` | 모듈 상세 정보 (파라미터) |
| Step 5 | `mcp__make__validate_module_configuration` | 모듈 설정 검증 |
| Step 6 | `mcp__make__scenarios_create` | 시나리오 생성 |
| Step 7 | `Read`, `Edit` | plan.md 업데이트 |

---

## 실행 지침

### Step 0: /setup 완료 확인

**Glob 도구 사용**:
```
pattern: "projects/*/plan.md"
```

**분기**:
- 결과 있음 → Step 1로 진행
- 결과 없음 → /setup 유도

**프로젝트 없을 때**:
```yaml
question: "프로젝트가 없습니다. /setup을 먼저 실행할까요?"
header: "Setup 필요"
options:
  - label: "예, /setup 실행"
    description: "프로젝트 초기 설정을 시작합니다"
  - label: "아니오, 취소"
    description: "나중에 다시 시도합니다"
```

**"예" 선택 시 메시지**:
```
🚀 /setup을 실행해주세요!

터미널에 다음 명령어를 입력하세요:
/setup

설정이 완료되면 다시 /new-scenario를 실행해주세요.
```

**"아니오" 선택 시 메시지**:
```
👋 알겠습니다. 나중에 다시 시도해주세요.

💡 Tip: /setup을 실행하면 프로젝트 디렉터리가 생성되고,
Airtable/Make 분석 결과가 저장됩니다.
```

---

### Step 1: 프로젝트 선택

**이전 단계에서 Glob 결과 활용**:

**프로젝트 1개일 때**:
```
📁 프로젝트: {프로젝트명}
이 프로젝트에서 시나리오를 생성합니다.
```

**프로젝트 여러개일 때**:
```yaml
question: "어떤 프로젝트에서 시나리오를 생성하시겠습니까?"
header: "프로젝트 선택"
options:
  # Glob 결과에서 동적 생성
  - label: "image-to-video"
    description: "projects/image-to-video/"
  - label: "sns-automation"
    description: "projects/sns-automation/"
```

---

### Step 2: 생성 방식 선택

```yaml
question: "시나리오를 어떻게 만드시겠습니까?"
header: "생성 방식"
options:
  - label: "자연어로 설명 (권장)"
    description: "원하는 것을 자유롭게 설명하면 시나리오를 설계합니다"
  - label: "템플릿 선택"
    description: "미리 준비된 템플릿에서 선택합니다"
```

---

### Step 2-A: 자연어 설명 (자유도 높음)

**"자연어로 설명" 선택 시**:

```
📝 어떤 자동화를 만들고 싶은지 자유롭게 설명해주세요.

예시:
- "Generated_Contents에 새 이미지가 추가되면 Runware로 영상을 만들고 싶어"
- "매일 아침 9시에 SNS_Posts에서 예약된 포스트를 인스타그램에 올려줘"
- "Content_Requests가 승인되면 Slack으로 알림 보내줘"

💡 테이블명, 트리거 방식, 원하는 결과를 포함하면 더 정확합니다.
```

**사용자 입력 후 처리**:
1. 입력 분석
2. 관련 테이블 확인 (`mcp__airtable__describe_table`)
3. 필요한 연결 파악
4. 시나리오 흐름 설계
5. Step 6 (시나리오 생성 확인)으로 이동

**설계 결과 예시**:
```
📋 시나리오 설계

📌 요청: "Generated_Contents에 새 이미지가 추가되면 영상으로 변환"

분석 결과:
- 트리거: Airtable Watch (Generated_Contents)
- 처리: Runware API로 영상 생성
- 저장: Generated_Video_Contents + Google Drive

시나리오 흐름:
1. Generated_Contents 새 레코드 감지
2. 이미지 URL 추출
3. Generated_Video_Contents 레코드 생성 (상태: 생성중)
4. Runware API 호출 (이미지 → 영상)
5. 영상 다운로드
6. Google Drive 업로드
7. Generated_Video_Contents 업데이트 (상태: 완료)

필요한 연결:
✅ Airtable OAuth (있음)
✅ Google Drive (있음)
✅ Runware.AI (있음)
```

---

### Step 2-B: 템플릿 선택 (구조화됨)

**"템플릿 선택" 선택 시**:

```yaml
question: "어떤 종류의 시나리오를 만드시겠습니까?"
header: "카테고리"
options:
  - label: "콘텐츠 생성"
    description: "이미지/영상 생성, AI 콘텐츠 제작"
  - label: "데이터 동기화"
    description: "Airtable ↔ Sheets, API 연동"
  - label: "SNS 자동화"
    description: "Instagram, Threads 자동 포스팅"
  - label: "워크플로우 자동화"
    description: "승인 프로세스, 알림 발송"
```

---

### Step 3: 세부 템플릿 선택

**"콘텐츠 생성" 선택 시**:
```yaml
question: "어떤 콘텐츠를 생성하시겠습니까?"
header: "템플릿"
options:
  - label: "이미지 → 영상 변환"
    description: "Kling/Runware로 이미지를 영상으로 변환"
  - label: "텍스트 → 이미지 생성"
    description: "Runware/DALL-E로 프롬프트에서 이미지 생성"
```

**"데이터 동기화" 선택 시**:
```yaml
question: "어떤 동기화를 하시겠습니까?"
header: "템플릿"
options:
  - label: "Airtable → Google Sheets"
    description: "Airtable 레코드를 Sheets로 동기화"
  - label: "외부 API → Airtable"
    description: "API 데이터를 Airtable에 저장"
```

**"SNS 자동화" 선택 시**:
```yaml
question: "어떤 SNS 기능을 자동화하시겠습니까?"
header: "템플릿"
options:
  - label: "자동 포스팅"
    description: "예약 시간에 자동으로 업로드"
  - label: "캡션 자동 생성"
    description: "AI로 이미지 분석 후 캡션 생성"
```

**"워크플로우 자동화" 선택 시**:
```yaml
question: "어떤 워크플로우를 자동화하시겠습니까?"
header: "템플릿"
options:
  - label: "승인 프로세스"
    description: "Slack/Email로 승인 요청"
  - label: "에러 알림"
    description: "시나리오 에러 시 Slack 알림"
```

---

### Step 4: 필요한 연결 확인

**mcp__make__connections_list 호출**:
```
teamId: 2759651  (또는 .env의 MAKE_TEAM_ID)
```

**템플릿별 필요 연결**:

| 템플릿 | 필요한 연결 |
|--------|------------|
| 이미지→영상 | Airtable, Google Drive, Runware.AI (또는 fal-ai) |
| 텍스트→이미지 | Airtable, Runware.AI |
| Airtable→Sheets | Airtable, Google Sheets |
| API→Airtable | Airtable |
| SNS 포스팅 | Airtable, Instagram/Threads |
| 캡션 생성 | Airtable, OpenAI (또는 Claude) |
| 승인 프로세스 | Airtable, Slack (또는 Email) |
| 에러 알림 | Slack |

**연결 비교 후 출력**:
```
🔗 필요한 연결 확인

✅ Airtable OAuth (12046948) - 있음
✅ Google Drive (12046957) - 있음
✅ Runware.AI (13479550) - 있음
❌ fal-ai - 없음 (선택적)

모든 필수 연결이 준비되었습니다!
```

**연결 부족 시**:
```
⚠️ 필요한 연결이 없습니다:
- Slack 연결이 필요합니다

Make.com에서 연결을 추가한 후 다시 시도해주세요:
https://eu2.make.com/2759651/connections
```

---

### Step 5: 상세 설정

**mcp__airtable__list_tables 호출**:
```
baseId: .env의 AIRTABLE_BASE_ID
```

**테이블 선택**:
```yaml
question: "어떤 테이블을 사용하시겠습니까?"
header: "테이블"
options:
  # list_tables 결과에서 동적으로 생성
  - label: "Generated_Contents"
    description: "생성된 이미지 관리"
  - label: "Content_Requests"
    description: "콘텐츠 생성 요청"
  - label: "SNS_Posts"
    description: "SNS 포스트 관리"
```

**트리거 방식 선택**:
```yaml
question: "시나리오를 어떻게 실행하시겠습니까?"
header: "트리거"
options:
  - label: "Watch (테이블 변경 감지)"
    description: "새 레코드 생성 시 자동 실행 (권장)"
  - label: "Webhook (외부 호출)"
    description: "URL 호출로 실행"
  - label: "Schedule (정해진 시간)"
    description: "매시간/매일 등 정기 실행"
```

---

### Step 6: 시나리오 생성 확인

**설계 요약 표시**:
```
📋 시나리오 설계 요약

📌 템플릿: 이미지 → 영상 변환
📁 테이블: Generated_Contents
⚡ 트리거: Watch (새 레코드 감지)

🔗 사용할 연결:
- Airtable OAuth (12046948)
- Google Drive (12046957)
- Runware.AI (13479550)

📊 시나리오 흐름:
1. Generated_Contents 새 레코드 감지
2. Generated_Video_Contents 레코드 생성
3. Runware로 영상 생성
4. Google Drive에 업로드
5. 상태 업데이트 (완료)
```

**확인 질문**:
```yaml
question: "이 설계로 시나리오를 생성할까요?"
header: "확인"
options:
  - label: "네, 생성합니다"
    description: "Make 시나리오를 생성합니다"
  - label: "설정 수정"
    description: "이전 단계로 돌아갑니다"
  - label: "취소"
    description: "생성을 취소합니다"
```

---

### Step 7: Make 시나리오 생성

**mcp__make__scenarios_create 호출**:
```json
{
  "teamId": 2759651,
  "scheduling": {
    "type": "indefinitely",
    "interval": 900
  },
  "blueprint": {
    // 템플릿별 청사진
    // blueprints/ 폴더에서 참조
  }
}
```

**참조할 청사진**:
- `blueprints/image-to-video.json` - 이미지→영상
- `blueprints/text-to-image.json` - 텍스트→이미지
- `blueprints/airtable-to-sheets.json` - Airtable→Sheets
- 등등...

---

### Step 8: 프로젝트 plan.md 업데이트

**projects/{name}/plan.md 수정**:

```markdown
## Tasks

### Task N: {시나리오 이름}
> **상태**: ✅ 생성됨
> **시나리오 ID**: {생성된 ID}
> **링크**: https://eu2.make.com/2759651/scenarios/{ID}/edit

- [x] 시나리오 생성
- [ ] 테스트 실행
- [ ] 활성화

---

## 변경 이력

| 날짜 | 버전 | 변경 내용 |
|------|------|----------|
| {오늘} | vX.X.X | {시나리오 이름} 시나리오 생성 |
```

---

### Step 9: 완료 안내

```
✅ 시나리오가 생성되었습니다!

🎬 시나리오: {이름}
🔗 링크: https://eu2.make.com/2759651/scenarios/{ID}/edit
📊 상태: 비활성화 (테스트 후 활성화 필요)

---

📝 다음 단계:

1. Make에서 시나리오 확인:
   위 링크를 클릭하여 시나리오 구조를 확인하세요

2. API 키 설정 (필요시):
   HTTP 모듈의 API 키를 설정하세요

3. 테스트 실행:
   "Run once" 버튼으로 테스트하세요

4. 활성화:
   테스트 성공 후 시나리오를 활성화하세요

---

💡 추가 명령어:
- /status    : 프로젝트 진행 상황 확인
- /backup    : 시나리오 청사진 백업
```

---

## 주의사항

1. **프로젝트 필수**: /setup 완료 후에만 실행 가능
2. **연결 확인**: 필요한 Make 연결이 있어야 시나리오 생성 가능
3. **청사진 참조**: blueprints/ 폴더의 JSON 파일 사용
4. **테스트 필요**: 생성 후 반드시 테스트 실행
5. **plan.md 업데이트**: 모든 변경사항 기록
