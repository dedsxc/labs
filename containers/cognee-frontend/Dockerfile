## cognee-frontend
##
## Upstream (topoteretes/cognee, cognee-frontend/) publishes no container image
## and ships only a dev-mode Dockerfile (`npm run dev`). This builds a proper
## production image: fetch the frontend source at the latest cognee release tag,
## `next build`, and serve with `next start`.
##
## NEXT_PUBLIC_* vars are inlined into the browser bundle at BUILD time, so the
## backend API URL must be baked here (not injected at runtime). The default is
## a same-origin relative path (`/api`); route that path to the cognee backend
## at the edge. Override with `--build-arg NEXT_PUBLIC_BACKEND_API_URL=...`.

## Stage 1: fetch the frontend source at the latest stable cognee release tag
FROM debian:stable-slim@sha256:ee12ffb55625b99d62837a72f037d9b2f18fd0c787a89c2b9a4f09666c48776c AS fetcher

RUN apt-get update && apt-get install -y --no-install-recommends curl jq ca-certificates

RUN LATEST_TAG=$(curl -sX GET "https://api.github.com/repos/topoteretes/cognee/releases" \
      | jq --raw-output '[.[] | select(.tag_name | test("^v?[0-9]+\\.[0-9]+\\.[0-9]+$"))][0].tag_name') \
    && echo "TAG=${LATEST_TAG}" > /tmp/version_info \
    && curl -fsSL "https://github.com/topoteretes/cognee/archive/refs/tags/${LATEST_TAG}.tar.gz" -o /tmp/cognee.tar.gz \
    && mkdir -p /tmp/cognee-src \
    && tar -xzf /tmp/cognee.tar.gz -C /tmp/cognee-src --strip-components=1 \
    && test -d /tmp/cognee-src/cognee-frontend

## Stage 2: install deps and build the Next.js app
FROM node:22-alpine@sha256:16e22a550f3863206a3f701448c45f7912c6896a62de43add43bb9c86130c3e2 AS builder

WORKDIR /app

COPY --from=fetcher /tmp/cognee-src/cognee-frontend/package.json /tmp/cognee-src/cognee-frontend/package-lock.json ./
RUN npm ci && npm rebuild lightningcss

COPY --from=fetcher /tmp/cognee-src/cognee-frontend/ ./
# Upstream ships both next.config.mjs and next.config.ts; Next.js refuses to
# start with two config files, so drop the empty .mjs and keep the .ts one.
RUN rm -f next.config.mjs

# NEXT_PUBLIC_* are inlined at build time. Default to a same-origin relative
# path so no environment-specific hostname is baked into the public image;
# route `/api` to the cognee backend at the edge (ingress/gateway).
ARG NEXT_PUBLIC_BACKEND_API_URL=/api
ARG NEXT_PUBLIC_IS_CLOUD_ENVIRONMENT=false
ENV NEXT_PUBLIC_BACKEND_API_URL=${NEXT_PUBLIC_BACKEND_API_URL}
ENV NEXT_PUBLIC_IS_CLOUD_ENVIRONMENT=${NEXT_PUBLIC_IS_CLOUD_ENVIRONMENT}
ENV NEXT_TELEMETRY_DISABLED=1

RUN npm run build

## Stage 3: runtime
FROM node:22-alpine@sha256:16e22a550f3863206a3f701448c45f7912c6896a62de43add43bb9c86130c3e2

WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000

# Non-root runtime user (matches the convention of other images in this repo).
RUN addgroup -g 10001 cognee && adduser -D -u 10001 -G cognee cognee

COPY --from=builder --chown=10001:10001 /app/package.json /app/package-lock.json ./
COPY --from=builder --chown=10001:10001 /app/node_modules ./node_modules
COPY --from=builder --chown=10001:10001 /app/.next ./.next
COPY --from=builder --chown=10001:10001 /app/public ./public
COPY --from=builder --chown=10001:10001 /app/next.config.ts ./

USER cognee

EXPOSE 3000

CMD ["npm", "run", "start"]
