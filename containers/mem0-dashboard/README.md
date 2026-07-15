# mem0-dashboard

Production container image for the [mem0](https://github.com/mem0ai/mem0)
self-hosted dashboard (`server/dashboard/`, a Next.js app), the web UI that sits
in front of the mem0 REST server.

## Why this exists

Upstream ships the dashboard source but publishes **no** container image. This
builds a proper production image:

1. **fetcher** — resolves the latest stable `mem0ai/mem0` release tag (proper
   `vX.Y.Z` only, skipping `ts-v*`/`cli-*`/`vercel-ai-v*` SDK tags), downloads
   the source tarball and extracts `server/dashboard/`.
2. **builder** — `pnpm install --frozen-lockfile`, then `next build` with
   `output: "standalone"` (already set in upstream `next.config.mjs`).
3. **runtime** — serves the standalone `server.js` as a non-root user
   (uid/gid `10001`) on port `3000`.

## Runtime configuration

`NEXT_PUBLIC_*` variables are inlined into the browser bundle at **build** time,
so they cannot normally be injected at runtime. Upstream works around this by
baking literal placeholders (`ENV NAME=NAME`) at build time and swapping them
for the container's real environment values at startup via `entrypoint.sh`.

That mechanism is preserved here, so these stay configurable at **runtime**:

| Env var | Purpose |
| --- | --- |
| `NEXT_PUBLIC_API_URL` | URL of the mem0 REST server the dashboard talks to |
| `NEXT_PUBLIC_INSTANCE_NAME` | Display name for the instance |

New `NEXT_PUBLIC_*` vars must be declared as `ENV NAME=NAME` in the Dockerfile
or `entrypoint.sh` won't substitute them.

## Runtime

- Listens on port `3000` (`PORT=3000`, `HOSTNAME=0.0.0.0`).
- `ENTRYPOINT` runs `entrypoint.sh` (placeholder substitution) then
  `CMD ["node", "server.js"]`.

## Versioning

`VERSION` resolves the latest stable `mem0ai/mem0` release tag (stripping the
leading `v`), so the image version tracks upstream mem0 releases, matching the
`mem0-server` container in this repo.
