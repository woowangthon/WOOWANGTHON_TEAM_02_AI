# WOOWANGTHON_TEAM_02_AI

BE가 선별한 공지 근거를 받아 답변을 생성하는 독립 FastAPI 서비스입니다. DB 접근, 계정 인증, 크롤링은 포함하지 않습니다.

## 로컬 실행

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -e .
$env:LLM_PROVIDER = "anthropic"
$env:LLM_API_KEY = "<provider key>"
$env:LLM_MODEL = "claude-haiku-5-5"
uvicorn notice_ai.api:app --app-dir src --reload --port 8001
```

`LLM_PROVIDER`는 `anthropic` 또는 `openai_compatible`입니다. OpenAI 호환 제공자는 선택적으로 `LLM_BASE_URL`을 지정합니다. 키는 환경변수로만 전달하고 저장소에 커밋하지 마세요.

## API 계약

`POST /v1/answer`

```json
{
  "question": "장학금 신청 마감일이 언제야?",
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

응답에는 `answer`, 전달받은 `evidence_ids`, `provider`, `prompt_tokens`, `completion_tokens`가 포함됩니다. `/health`는 서비스 상태를 확인합니다. BE는 인증/접근 권한을 확인하고 사용자에게 허용된 공지만 이 API에 전달해야 합니다.

## 컨테이너

```powershell
docker build -t woowangthon-ai .
docker run --rm -p 8001:8001 -e LLM_API_KEY -e LLM_PROVIDER -e LLM_MODEL woowangthon-ai
```
