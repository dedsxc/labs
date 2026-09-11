FROM python:3.14.7-slim-bookworm

ARG GARMIN_MCP_COMMIT=3610be6feed93088d85b0f35aba9d7d07c2505a7

LABEL org.opencontainers.image.source="https://github.com/dedsxc/labs" \
      org.opencontainers.image.description="Garmin Connect MCP server"

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    HOME=/home/garmin

RUN apt-get update \
    && apt-get install --no-install-recommends -y git ca-certificates \
    && python -m pip install "git+https://github.com/Taxuspt/garmin_mcp.git@${GARMIN_MCP_COMMIT}" \
    && apt-get purge -y --auto-remove git \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --home-dir /home/garmin --uid 10001 garmin \
    && install -d -o garmin -g garmin -m 0700 /home/garmin/.garminconnect /data/activities

USER 10001:10001
WORKDIR /home/garmin
EXPOSE 8000

ENTRYPOINT ["garmin-mcp"]
