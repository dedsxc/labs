## Stage 1: Fetch the mem0 server source at the latest stable release tag
FROM debian:stable-slim@sha256:ee12ffb55625b99d62837a72f037d9b2f18fd0c787a89c2b9a4f09666c48776c AS fetcher

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
FROM python:3.12-slim@sha256:423ed6ab25b1921a477529254bfeeabf5855151dc2c3141699a1bfc852199fbf

WORKDIR /app

COPY --from=fetcher /tmp/version_info /tmp/version_info
COPY --from=fetcher /tmp/mem0-src/server/. /app/

RUN pip install --no-cache-dir -r requirements.txt

RUN useradd --create-home --uid 10001 mem0 \
    && chown -R mem0:mem0 /app

USER mem0

EXPOSE 8000

ENV PYTHONUNBUFFERED=1

# Run pending Alembic migrations then start the API (no --reload in prod)
CMD ["sh", "-c", "alembic upgrade head && uvicorn main:app --host 0.0.0.0 --port 8000"]
