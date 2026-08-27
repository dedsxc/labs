FROM python:3.12-slim

ARG OPENSRE_COMMIT=7eef52a0304405b1a4174f322d286bcc4d805f5f

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    HOME=/home/opensre \
    PORT=8000 \
    MODE=web

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential ca-certificates git \
    && git clone https://github.com/Tracer-Cloud/opensre.git /src opensre \
    && cd /src opensre && git checkout --detach "${OPENSRE_COMMIT}" \
    && python -m pip install --upgrade pip \
    && python -m pip install "./src/opensre[postgresql]" \
    && rm -rf /src /root/.cache /var/lib/apt/lists/* \
    && apt-get purge -y --auto-remove build-essential git \
    && groupadd --gid 1000 opensre \
    && useradd --uid 1000 --gid 1000 --create-home --shell /usr/sbin/nologin opensre \
    && mkdir -p /workspace/scratch /home/opensre/.opensre \
    && chown -R opensre:opensre /workspace /home/opensre

USER 1000:1000
WORKDIR /workspace
EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/healthz', timeout=5)" || exit 1

CMD ["sh", "-c", "exec uvicorn gateway.web.webapp:app --host 0.0.0.0 --port ${PORT:-8000}"]
