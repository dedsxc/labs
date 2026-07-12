# cognee-frontend

Production container image for the [cognee](https://github.com/topoteretes/cognee)
web UI (`cognee-frontend/`, a Next.js app).

## Why this exists

Upstream publishes **no** container image for the frontend and ships only a
dev-mode `Dockerfile` (`npm run dev`). This builds a proper production image:

1. **fetcher** — resolves the latest stable `topoteretes/cognee` release tag,
   downloads the source tarball and extracts `cognee-frontend/`.
2. **builder** — `npm ci`, drops the conflicting `next.config.mjs` (upstream
   ships both `.mjs` and `.ts`, and Next.js refuses to start with two configs),
   then `next build`.
3. **runtime** — serves with `next start` as a non-root user (uid/gid `10001`).

## Build-time configuration

`NEXT_PUBLIC_*` variables are inlined into the browser bundle at **build** time,
so they cannot be injected at runtime. They are baked via build args:

| Build arg | Default |
| --- | --- |
| `NEXT_PUBLIC_BACKEND_API_URL` | `/api` (same-origin relative path) |
| `NEXT_PUBLIC_IS_CLOUD_ENVIRONMENT` | `false` |

The `dedsxc/labs` release workflow passes no build args, so the defaults above
are what ship in the published image. The default is a **same-origin relative
path** so no environment-specific hostname is baked into this public image;
route `/api` to the cognee backend at the edge (ingress/gateway).

## Runtime

- Listens on port `3000` (`PORT=3000`).
- `CMD ["npm", "run", "start"]` → `next start`.

## Versioning

`VERSION` resolves the latest stable `topoteretes/cognee` release tag (stripping
the leading `v`), so the image version tracks upstream cognee releases.
