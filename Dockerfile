FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app
COPY pyproject.toml README.md ./
COPY src ./src
RUN pip install --no-cache-dir .

EXPOSE 8001
CMD ["sh", "-c", "exec uvicorn notice_ai.api:app --host 0.0.0.0 --port ${PORT:-8001}"]
