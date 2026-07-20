## mem0-dashboard
##
## Upstream (mem0ai/mem0, server/dashboard/) ships a Next.js dashboard for the
## self-hosted mem0 REST server but publishes no container image. This builds a
## proper production image: fetch the dashboard source at the latest stable mem0
## release tag, `next build` (standalone output), and serve `server.js`.
##
## NEXT_PUBLIC_* vars are inlined into the browser bundle at BUILD time. Upstream
## works around this by baking literal placeholders (ENV NAME=NAME) and swapping
## them for the container's real env values at startup via entrypoint.sh, so the
## API URL / instance name stay configurable at RUNTIME. We keep that mechanism.

## Stage 1: fetch the dashboard source at the latest stable mem0 release tag
FROM debian:stable-slim@sha256:328d16499860ae6cb9b345e2e4cebca08c2a36e4f7278482c7bd1f39d71e5bfd AS fetcher

RUN apt-get update && apt-get install -y --no-install-recommends curl jq ca-certificates

# Only consider proper "vX.Y.Z" releases of the core mem0ai package (skip
# sdk-specific tags like ts-v*, cli-*, vercel-ai-v*).
RUN LATEST_TAG=$(curl -sX GET "https://api.github.com/repos/mem0ai/mem0/releases" \
      | jq --raw-output '[.[] | select(.tag_name | test("^v[0-9]+\\.[0-9]+\\.[0-9]+$"))][0].tag_name') \
    && echo "TAG=${LATEST_TAG}" > /tmp/version_info \
    && curl -fsSL "https://github.com/mem0ai/mem0/archive/refs/tags/${LATEST_TAG}.tar.gz" -o /tmp/mem0.tar.gz \
    && mkdir -p /tmp/mem0-src \
    && tar -xzf /tmp/mem0.tar.gz -C /tmp/mem0-src --strip-components=1 \
    && test -d /tmp/mem0-src/server/dashboard

## Stage 2: install deps and build the Next.js app (pnpm, standalone output)
FROM node:22-alpine@sha256:16e22a550f3863206a3f701448c45f7912c6896a62de43add43bb9c86130c3e2 AS builder

RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY --from=fetcher /tmp/mem0-src/server/dashboard/ ./
RUN corepack enable pnpm && pnpm install --frozen-lockfile

ENV NEXT_TELEMETRY_DISABLED=1
# NEXT_PUBLIC_* are inlined at build time. Bake literal placeholders (name ==
# value) so entrypoint.sh can swap them for real env values at runtime. Each
# placeholder MUST be declared here for the substitution to work.
ENV NEXT_PUBLIC_API_URL=NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_INSTANCE_NAME=NEXT_PUBLIC_INSTANCE_NAME

RUN pnpm run build

## Stage 3: runtime
FROM node:22-alpine@sha256:16e22a550f3863206a3f701448c45f7912c6896a62de43add43bb9c86130c3e2

RUN apk add --no-cache libc6-compat
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Non-root runtime user (matches the convention of other images in this repo).
RUN addgroup -g 10001 mem0 && adduser -D -u 10001 -G mem0 mem0

# Standalone output bundles a minimal server.js + only the needed node_modules.
COPY --from=builder /app/public ./public
COPY --from=builder --chown=10001:10001 /app/.next/standalone ./
COPY --from=builder --chown=10001:10001 /app/.next/static ./.next/static
COPY --from=builder --chown=10001:10001 /app/entrypoint.sh /home/mem0/entrypoint.sh
RUN chmod +x /home/mem0/entrypoint.sh

USER mem0

EXPOSE 3000

ENTRYPOINT ["/home/mem0/entrypoint.sh"]
CMD ["node", "server.js"]
