# AI 인수인계

## 역할

- 이 저장소는 모델 제공자 API를 호출해 공지 기반 답변·생성형 요약·게시판 selector 후보를 만드는 독립 FastAPI 서비스입니다.
- 앱 코드는 `src/notice_ai/`에 있습니다. `src`는 Python 소스 루트이고 `notice_ai/api.py`가 FastAPI 진입점입니다.
- BE가 사용자 인증과 학교별 공지 권한을 확인한 뒤 근거 공지만 전달합니다. AI는 사용자 계정, DB, 공지 검색, 크롤링을 직접 처리하지 않습니다.
- 웹사이트는 BE의 `http://localhost:8000`에서 실행됩니다. AI 서비스 포트 8001은 BE가 내부 호출하는 서비스 주소이며 사용자가 웹 UI에 접속할 주소가 아닙니다.

## API 계약

모든 `/v1` 작업 API는 `X-AI-Service-Token` 헤더를 요구합니다. AI와 BE의 `AI_SERVICE_TOKEN` 설정은 서로 같아야 합니다.

- `POST /v1/answer`: `question`과 BE가 선별한 `evidence[]`를 받아 답변, 사용한 공지 ID 및 토큰 사용량을 반환합니다.
- `POST /v1/summarize`: `notice` 하나를 받아 공지 본문에 근거한 요약을 반환합니다.
- `POST /v1/suggest-parser`: 제공된 HTML 일부에서 공지 목록 selector 후보를 생성합니다. BE가 반드시 후보를 실제 파서로 검증합니다.
- `GET /health`: 연결 상태를 반환하며 내부 토큰 없이 확인할 수 있습니다.

외부 API나 모델 호출은 `src/notice_ai/api.py`의 `_generate()`에 모읍니다. 제공자별 호출과 prompt를 BE에 복제하지 않습니다. 각 작업의 prompt 함수도 AI 코드 안에서 관리합니다.

## 설정과 실행

- `LLM_PROVIDER`: `google`, `anthropic`, `openai`, `openai_compatible`
- `LLM_API_KEY`: 선택된 모델 제공자 키. AI 서비스 환경변수에만 저장하고 저장소에는 올리지 않습니다.
- `LLM_MODEL`, 선택사항 `LLM_BASE_URL`
- `AI_SERVICE_TOKEN`: BE와 공유하는 내부 서비스 인증 토큰. 사용자 브라우저에 노출하지 않습니다.
- 기본 서비스 포트: `8001`; BE는 기본 `AI_SERVICE_URL=http://host.docker.internal:8001`로 호출합니다.

`AI/.env.example`을 복사해 `AI/.env`를 만들고 로컬 값을 설정한 뒤, AI 디렉터리에서 `uvicorn notice_ai.api:app --app-dir src --host 0.0.0.0 --port 8001`로 실행합니다. 컨테이너 실행 방법과 provider 상세는 `README.md`를 참고하세요.

현재 개발 환경의 `AI/.env`는 로컬 전용 파일입니다. 커밋하거나 내용을 출력하지 마세요. 커밋할 설정 예시는 `.env.example`만 사용합니다.

## GitHub 상태와 다음 단계

- 기본 브랜치는 `main`입니다.
- AI 구조 분리 커밋 `4befd55`까지 GitHub `main`에 푸시되어 있습니다.
- BE 변경은 BE 저장소 `main`에 푸시되어 있으며, FE는 AI를 직접 호출하지 않습니다.
- 마지막 구조 변경에서 자동 테스트를 실행하지 않았습니다. 배포 전 `/health`, 인증 헤더가 있는 API 연결, 답변·요약을 확인합니다.
