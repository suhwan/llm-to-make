# LLM-to-Make Project Plan

> **Version**: v2.1.0
> **Last Updated**: 2026-01-10
> **Status**: ✅ 온보딩 시스템 v1.0 완료

---

## Project Overview

비개발자가 자연어로 Make 시나리오를 개발할 수 있도록 지원하는 프로젝트

### Goals
- 자연어 입력 → Task 분석 → Make 시나리오 자동 생성
- Claude Code 기능 최대 활용 (Skills, Subagents, MCP Plugins)

---

## Available Resources

### MCP Plugins (Connected)
| Plugin | Usage |
|--------|-------|
| Make | 시나리오 CRUD, 모듈 조회, 도구 생성 |
| Airtable | 테이블/레코드 관리 |
| GitHub | PR 생성, 코드 리뷰 |
| Playwright | E2E 테스트 |
| Google Drive | 파일 관리 |

### Subagents
| Agent | Best For |
|-------|----------|
| Explore | 코드베이스 탐색, 파일 검색 |
| Plan | 아키텍처 설계, 구현 전략 |
| Bash | Git, 시스템 명령 |
| general-purpose | 복잡한 조사/분석 |

### Existing Assets
- **Airtable Base**: suwhan (appzQEgOxUpCYGmk7)
  - Models, Content_Requests, Generated_Contents, Prompt_Templates, Gen Models, Model_Personas, SNS_Posts
- **Make Organization**: 에드스파크 (Team ID: 2759651)
  - Scenario #8388904 (참조용)

---

## Workflow

```
[자연어 계획 입력]
        ↓
[Task 분석 & 분해] ← Subagent: Plan
        ↓
[세부 계획 작성] → plan.md 업데이트
        ↓
[사용자 승인]
        ↓
[Task N 개발] ← MCP Plugins (Make, Airtable, etc.)
        ↓
[코드 리뷰] ← 로컬 + GitHub PR
        ↓
[plan.md 체크 표시]
        ↓
[다음 Task로 반복]
```

---

## Feature-to-Tool Mapping

| 작업 유형 | 추천 도구 | 이유 |
|----------|----------|------|
| 반복 작업 (sync, 체크) | **Skills** | 명령어로 빠른 실행 |
| 복잡한 분석/탐색 | **Subagents** | 자율적 멀티스텝 처리 |
| Make 시나리오 생성 | **MCP: Make** | 직접 API 연동 |
| 데이터 관리 | **MCP: Airtable** | 테이블 CRUD |
| 코드 리뷰/PR | **MCP: GitHub** | PR 생성 및 리뷰 |
| 계획 추적 | **TodoWrite** | 실시간 동기화 |

---

## Current Scenario: 이미지→영상 변환 자동화

### 시나리오 흐름도 (Phase 2: Multi-Segment)

```
[Generated_Contents 테이블]
        ↓ (Video_Count: 1~3)
[Video_Segments 생성] ← 세그먼트별 레코드 자동 생성
        ↓
[Iterator: 각 세그먼트 순회]
        ↓
[프롬프트 분기]
├── Use_Common_Prompt=true → Common_Video_Prompt 사용
└── Use_Common_Prompt=false → Segment_Prompt 사용
        ↓
[영상 생성 AI]
├── fal-ai (Kling 1.0)
└── Runway ML (Gen-4 Turbo)
        ↓ (세그먼트별 영상)
[Video_Segments 업데이트]
        ↓ (모든 세그먼트 완료 시)
[FFmpeg - 영상 연결] ← Phase 2
        ↓ (최종 영상)
[저장]
├── Airtable (Final_Video 필드)
└── Google Drive (파일 백업)
```

### 청사진 파일

📁 `blueprints/image-to-video-v1.json`
🔗 **Make 시나리오**: [#8436833](https://eu2.make.com/2759651/scenarios/8436833/edit)

---

## Version History

| Version | Date | Changes |
|---------|------|--------|
| v1.0.0 | 2026-01-08 | 초기 계획 문서 생성 |
| v1.1.0 | 2026-01-08 | 이미지→영상 변환 시나리오 Task 분해 (7개 Task) |
| v2.0.0 | 2026-01-10 | **LLM-to-Make 템플릿 v1.0**: CLAUDE.md, table-schema.md, scenario-templates.md 생성 |
| v2.1.0 | 2026-01-10 | **온보딩 시스템 v1.0**: onboarding.md, /setup 스킬, .env.example 생성 |
