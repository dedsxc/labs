## Stage 1: Fetch the mem0 server source at the latest stable release tag
FROM debian:stable-slim@sha256:328d16499860ae6cb9b345e2e4cebca08c2a36e4f7278482c7bd1f39d71e5bfd AS fetcher

RUN apt-get update && apt-get install -y --no-install-recommends curl jq ca-certificates

# Only consider proper "vX.Y.Z" releases of the core mem0ai package (skip
# sdk-specific tags like ts-v*, cli-*, vercel-ai-v*).
RUN LATEST_TAG=$(curl -sX GET "https://api.github.com/repos/mem0ai/mem0/releases" \
      | jq --raw-output '[.[] | select(.tag_name | test("^v[0-9]+\\.[0-9]+\\.[0-9]+$"))][0].tag_name') \
    && echo "TAG=${LATEST_TAG}" > /tmp/version_info \
    && curl -fsSL "https://github.com/mem0ai/mem0/archive/refs/tags/${LATEST_TAG}.tar.gz" -o /tmp/mem0.tar.gz \
    && mkdir -p /tmp/mem0-src \
    && tar -xzf /tmp/mem0.tar.gz -C /tmp/mem0-src --strip-components=1

## Stage 2: Build the runtime image
FROM python:3.14-slim@sha256:cea0e6040540fb2b965b6e7fb5ffa00871e632eef63719f0ea54bca189ce14a6

WORKDIR /app

COPY --from=fetcher /tmp/version_info /tmp/version_info
COPY --from=fetcher /tmp/mem0-src/server/. /app/

# upstream requirements.txt pins bare "psycopg" (source build), which
# needs libpq installed on the system and fails at runtime with
# "no pq wrapper available" on this slim image. Force the prebuilt
# binary wheel instead (same fix used in mem0's own self-host guide).
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir --force-reinstall "psycopg[binary]>=3.2.8"

RUN useradd --create-home --uid 10001 mem0 \
    && chown -R mem0:mem0 /app

USER mem0

EXPOSE 8000

ENV PYTHONUNBUFFERED=1

# Run pending Alembic migrations then start the API (no --reload in prod)
CMD ["sh", "-c", "alembic upgrade head && uvicorn main:app --host 0.0.0.0 --port 8000"]
