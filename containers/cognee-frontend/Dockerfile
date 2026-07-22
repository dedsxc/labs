## cognee-frontend
##
## Upstream (topoteretes/cognee, cognee-frontend/) ships the Next.js web UI for
## Cognee but publishes no container image, and its own Dockerfile runs the app
## in dev mode (`npm run dev`). This builds a proper production image: fetch the
## frontend source at the latest stable cognee release tag, `next build` with
## standalone output, and serve `server.js` as a non-root user.
##
## NEXT_PUBLIC_* vars are inlined into the browser bundle at BUILD time. We bake
## literal placeholders (ENV NAME=NAME) and swap them for the container's real
## env values at startup via entrypoint.sh, so the backend API URL and mode stay
## configurable at RUNTIME.

## Stage 1: fetch the frontend source at the latest stable cognee release tag
FROM debian:stable-slim@sha256:328d16499860ae6cb9b345e2e4cebca08c2a36e4f7278482c7bd1f39d71e5bfd AS fetcher

RUN apt-get update && apt-get install -y --no-install-recommends curl jq ca-certificates

# Only consider proper "vX.Y.Z" releases (skip prerelease .devN tags).
RUN LATEST_TAG=$(curl -sX GET "https://api.github.com/repos/topoteretes/cognee/releases" \
      | jq --raw-output '[.[] | select(.tag_name | test("^v[0-9]+\\.[0-9]+\\.[0-9]+$"))][0].tag_name') \
    && curl -fsSL "https://github.com/topoteretes/cognee/archive/refs/tags/${LATEST_TAG}.tar.gz" -o /tmp/cognee.tar.gz \
    && mkdir -p /tmp/cognee-src \
    && tar -xzf /tmp/cognee.tar.gz -C /tmp/cognee-src --strip-components=1 \
    && test -d /tmp/cognee-src/cognee-frontend

## Stage 2: install deps and build the Next.js app (npm, standalone output)
FROM node:24-alpine@sha256:a0b9bf06e4e6193cf7a0f58816cc935ff8c2a908f81e6f1a95432d679c54fbfd AS builder

RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY --from=fetcher /tmp/cognee-src/cognee-frontend/ ./
RUN npm ci && npm rebuild lightningcss

# Upstream's next.config.mjs does not enable standalone output (nor keep the
# googleusercontent image host from next.config.ts). Override it so `next build`
# emits a self-contained server.js bundle we can run without the full repo.
RUN printf '%s\n' \
      '/** @type {import("next").NextConfig} */' \
      'const nextConfig = {' \
      '  output: "standalone",' \
      '  images: {' \
      '    remotePatterns: [{ protocol: "https", hostname: "lh3.googleusercontent.com" }],' \
      '  },' \
      '};' \
      'export default nextConfig;' \
      > next.config.mjs \
    && rm -f next.config.ts

ENV NEXT_TELEMETRY_DISABLED=1
# NEXT_PUBLIC_* are inlined at build time. Bake literal placeholders (name ==
# value) so entrypoint.sh can swap them for real env values at runtime. Each
# placeholder MUST be declared here for the substitution to work.
ENV NEXT_PUBLIC_LOCAL_API_URL=NEXT_PUBLIC_LOCAL_API_URL
ENV NEXT_PUBLIC_IS_CLOUD_ENVIRONMENT=NEXT_PUBLIC_IS_CLOUD_ENVIRONMENT
ENV NEXT_PUBLIC_COGWIT_API_KEY=NEXT_PUBLIC_COGWIT_API_KEY

# v1.4.0 carries a stale suppression above the d3-force-3d dynamic import.
# The dependency now provides types, so TypeScript rejects the unused directive.
# It also requests the datasets collection with a trailing slash while the API
# declares the route without one. FastAPI redirects that request using the
# internal HTTP scheme behind Traefik; browsers then block the HTTPS-to-HTTP
# redirect. Use the canonical no-trailing-slash URL and avoid the redirect.
RUN sed -i '/@ts-expect-error d3-force-3d has no types/d' \
      'src/app/(graph)/GraphVisualization.tsx' \
    && sed -i \
      -e 's|instance.fetch("/v1/datasets/",|instance.fetch("/v1/datasets",|' \
      -e 's|instance.fetch(`/v1/datasets/`,|instance.fetch(`/v1/datasets`,|' \
      'src/modules/datasets/getDatasets.ts' \
      'src/modules/datasets/createDataset.ts'

RUN npm run build

## Stage 3: runtime
FROM node:24-alpine@sha256:a0b9bf06e4e6193cf7a0f58816cc935ff8c2a908f81e6f1a95432d679c54fbfd

RUN apk add --no-cache libc6-compat
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"
# Default to OSS/local mode; the shared frontend defaults to cloud otherwise.
ENV NEXT_PUBLIC_IS_CLOUD_ENVIRONMENT=false
ENV NEXT_PUBLIC_LOCAL_API_URL=http://localhost:8000

# Non-root runtime user (matches the convention of other images in this repo).
RUN addgroup -g 10001 cognee && adduser -D -u 10001 -G cognee cognee

# Standalone output bundles a minimal server.js + only the needed node_modules.
COPY --from=builder --chown=10001:10001 /app/public ./public
COPY --from=builder --chown=10001:10001 /app/.next/standalone ./
COPY --from=builder --chown=10001:10001 /app/.next/static ./.next/static
COPY --chown=10001:10001 entrypoint.sh /home/cognee/entrypoint.sh
RUN chmod +x /home/cognee/entrypoint.sh

USER cognee

EXPOSE 3000

ENTRYPOINT ["/home/cognee/entrypoint.sh"]
CMD ["node", "server.js"]
