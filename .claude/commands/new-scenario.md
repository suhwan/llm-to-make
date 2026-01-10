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
