# cognee-frontend

Production container image for the [Cognee](https://github.com/topoteretes/cognee)
web UI (`cognee-frontend/`, a Next.js app), the browser frontend that sits in
front of the Cognee API.

## Why this exists

Upstream ships the frontend source but publishes **no** container image, and its
own `Dockerfile` runs the app in development mode (`npm run dev`). This builds a
proper production image:

1. **fetcher** — resolves the latest stable `topoteretes/cognee` release tag
   (proper `vX.Y.Z` only, skipping `.devN` prereleases), downloads the source
   tarball and extracts `cognee-frontend/`.
2. **builder** — `npm ci` + `npm rebuild lightningcss`, injects a
   `next.config.mjs` that enables `output: "standalone"` (upstream sets neither
   standalone output nor a single canonical config), then `next build`.
3. **runtime** — serves the standalone `server.js` as a non-root user
   (uid/gid `10001`) on port `3000`.

## Runtime configuration

`NEXT_PUBLIC_*` variables are inlined into the browser bundle at **build** time,
so they cannot normally be injected at runtime. This image bakes literal
placeholders (`ENV NAME=NAME`) at build time and swaps them for the container's
real environment values at startup via `entrypoint.sh`.

That keeps these configurable at **runtime**:

| Env var | Purpose | Default |
| --- | --- | --- |
| `NEXT_PUBLIC_LOCAL_API_URL` | Base URL of the Cognee API the UI talks to (local/OSS mode) | `http://localhost:8000` |
| `NEXT_PUBLIC_IS_CLOUD_ENVIRONMENT` | `false` selects OSS/local mode; anything else is cloud mode | `false` |
| `NEXT_PUBLIC_COGWIT_API_KEY` | Optional API key for authenticated requests | _(unset)_ |

New `NEXT_PUBLIC_*` vars must be declared as `ENV NAME=NAME` in the Dockerfile
**and** listed in `entrypoint.sh`, or the substitution won't happen.

## Runtime

- Listens on port `3000` (`PORT=3000`, `HOSTNAME=0.0.0.0`).
- `ENTRYPOINT` runs `entrypoint.sh` (placeholder substitution) then
  `CMD ["node", "server.js"]`.
- Ships in OSS/local mode by default (`NEXT_PUBLIC_IS_CLOUD_ENVIRONMENT=false`).

## Platform

Built for `linux/amd64` only, matching the other Next.js image in this repo
(`mem0-dashboard`) whose `arm64` build fails under the CI's QEMU emulation. This
is a web UI with no need to run on arm nodes; schedule the pod on an amd64 node
(e.g. a `nodeSelector`).

## Versioning

`VERSION` resolves the latest stable `topoteretes/cognee` release tag (stripping
the leading `v`), so the image version tracks upstream cognee releases.
