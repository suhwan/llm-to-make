# LLM-to-Make 첫 사용자 가이드

## Step 1: API 키 발급

### Make.com API 토큰
1. Make.com에 로그인
2. Profile → API → Create a token

### Airtable API 키
1. https://airtable.com/create/tokens
2. 필요한 스코프 추가

## Step 2: .env 파일 설정

```bash
MAKE_ZONE=eu2.make.com
MAKE_MCP_TOKEN=your_token
AIRTABLE_API_KEY=your_token
AIRTABLE_BASE_ID=your_base_id
```

## Step 3: 첫 명령어 실행

```
/setup
```
