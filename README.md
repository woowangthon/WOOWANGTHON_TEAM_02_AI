# WOOWANGTHON_TEAM_02_AI

BE가 선별한 공지 근거로 답변·요약을 만들고, 공지와 무관한 질문에는 Google Search 기반 웹 답변을 제공하는 독립 FastAPI 서비스입니다. 게시판 selector 제안도 지원합니다. DB 접근, 사용자 계정 인증, 공지 권한 판정, 크롤링은 포함하지 않습니다. 사용자 인증과 학교별 공지 접근 검사는 BE가 담당합니다.

## 로컬 실행

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -e .
Copy-Item .env.example .env
# .env의 AI_SERVICE_TOKEN과 LLM_API_KEY를 설정한 후 현재 PowerShell 세션에 불러옵니다.
Get-Content .env | Where-Object { $_ -match '^\s*[^#][^=]*=' } | ForEach-Object {
  $parts = $_ -split '=', 2
  [Environment]::SetEnvironmentVariable($parts[0], $parts[1], 'Process')
}
uvicorn notice_ai.api:app --app-dir src --host 0.0.0.0 --port 8001
```

`LLM_PROVIDER`는 `google`, `anthropic`, `openai`, `openai_compatible` 중 하나입니다. OpenAI 호환 제공자는 선택적으로 `LLM_BASE_URL`을 지정합니다. 실제 제공자 키는 `AI/.env`에만 두고 저장소에 커밋하지 마세요. `AI_SERVICE_TOKEN`은 BE의 `AI_SERVICE_TOKEN`과 동일한 임의의 비밀값으로 설정하세요.

## API 계약

AI 작업용 API는 `X-AI-Service-Token` 내부 인증 헤더를 요구합니다. 키와 토큰을 로그나 브라우저에 노출하지 마세요.

`POST /v1/answer`

```json
{
  "question": "장학금 신청 마감일이 언제야?",
  "web_search": false,
  "evidence": [
    {
      "id": "notice-123",
      "title": "2026학년도 장학금 신청 안내",
      "content": "공지 본문 또는 요약",
      "source": "컴퓨터공학과",
      "posted_at": "2026-11-10",
      "url": "https://example.edu/notice/123"
    }
  ]
}
```

`web_search`를 `true`로 보내면 Google Search grounding으로 일반 웹 질문에 답하고, 응답의 `sources`에 제목과 URL을 반환합니다. BE는 공지 검색 결과가 없을 때만 이 옵션을 사용합니다. 일반 공지 답변은 전달된 공지 내용만 사용합니다. 응답에는 `answer`, `evidence_ids`, `sources`, `provider`, `prompt_tokens`, `completion_tokens`가 포함됩니다.

웹 검색에는 Google Gemini의 Google Search grounding이 필요하며, Gemini 3 계열의 검색 grounding은 유료 등급 활성화가 필요할 수 있습니다. 무료 제공량 초과 시 요금이 발생할 수 있으므로 Google의 [최신 가격표](https://ai.google.dev/gemini-api/docs/pricing)를 확인하세요.

- `POST /v1/summarize`: `{ "notice": { "id", "title", "content", "source", "posted_at", "url" } }`를 받아 생성형 요약을 반환합니다.
- `POST /v1/suggest-parser`: `{ "html": "..." }`을 받아 공지 목록 selector 후보를 반환합니다. 실제 페이지 적용 가능성은 BE가 검증합니다.
- `GET /health`: 서비스 상태를 인증 없이 확인합니다.

BE는 인증/접근 권한을 확인하고 사용자에게 허용된 공지만 이 API에 전달해야 합니다. Docker Compose의 BE 컨테이너는 기본적으로 `host.docker.internal:8001`의 AI 서비스를 사용합니다. 다른 실행 환경에서는 BE의 `AI_SERVICE_URL`을 AI 서비스 주소로 설정하세요.

## 컨테이너

```powershell
docker build -t woowangthon-ai .
docker run --rm -p 8001:8001 --env-file .env woowangthon-ai
```
