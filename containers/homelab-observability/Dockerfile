FROM node:22-alpine AS builder
ARG APP_COMMIT=09287a4
WORKDIR /app
RUN apk add --no-cache git \
  && git clone https://github.com/dedsxc/homelab-observability.git . \
  && git checkout --detach "${APP_COMMIT}"
RUN npm ci
ENV NEXT_TELEMETRY_DISABLED=1
RUN npm run build

FROM node:22-alpine
WORKDIR /app
ENV NODE_ENV=production NEXT_TELEMETRY_DISABLED=1 PORT=3000 HOSTNAME=0.0.0.0
RUN addgroup -g 10001 kino && adduser -D -u 10001 -G kino kino
COPY --from=builder --chown=10001:10001 /app/public ./public
COPY --from=builder --chown=10001:10001 /app/.next/standalone ./
COPY --from=builder --chown=10001:10001 /app/.next/static ./.next/static
USER 10001:10001
EXPOSE 3000
CMD ["node", "server.js"]
