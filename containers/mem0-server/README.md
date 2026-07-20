# mem0-server

Self-hosted [Mem0](https://github.com/mem0ai/mem0) server (`server/` subfolder of the
upstream repo) — long-term memory API for AI agents, backed by Postgres/pgvector.

Upstream ships no official container image for this component (only `openmemory-mcp`
is published), so this Dockerfile builds it from source.

## Build

- **Stage 1** resolves the latest stable `vX.Y.Z` release tag of `mem0ai/mem0`
  (skips SDK-only tags like `ts-v*`, `cli-*`, `vercel-ai-v*`) and downloads the
  `server/` subfolder from that tag.
- **Stage 2** installs `server/requirements.txt` (which pins `mem0ai>=0.1.48`
  from PyPI) on top of `python:3.12-slim`, and runs as a non-root user
  (uid/gid `10001`, matching the convention used by other agent-style images
  in this repo, e.g. `openhands/agent-canvas`).

## Runtime

Entrypoint runs pending Alembic migrations before starting uvicorn:

```
alembic upgrade head && uvicorn main:app --host 0.0.0.0 --port 8000
```

## Required environment

See upstream [`server/.env.example`](https://github.com/mem0ai/mem0/blob/main/server/.env.example):

- `POSTGRES_HOST` / `POSTGRES_PORT` / `POSTGRES_DB` / `POSTGRES_USER` / `POSTGRES_PASSWORD`
  — Postgres with the `vector` extension enabled (used for the memory vector store).
- `APP_DB_NAME` — separate database for user/auth/api-key data (default `mem0_app`).
  Must exist before the migrations run (this repo's cnpg-cluster provisions it
  via `database.list[]`).
- `JWT_SECRET`, `ADMIN_API_KEY` — auth.
- `OPENAI_API_KEY` / `OPENAI_BASE_URL` (or `ANTHROPIC_API_KEY`, `GOOGLE_API_KEY`)
  — LLM/embedder provider used to extract and embed memories. Point
  `OPENAI_BASE_URL` at LiteLLM to route through the existing gateway.
- `MEM0_DEFAULT_LLM_MODEL`, `MEM0_DEFAULT_EMBEDDER_MODEL` — override the default
  models without rebuilding the image.
