FROM node:24-alpine@sha256:4f696fbf39f383c1e486030ba6b289a5d9af541642fc78ab197e584a113b9c03 AS base

# Install dependencies only when needed
FROM base AS build

RUN apk add --no-cache libc6-compat git

RUN git clone --depth 1  https://github.com/GoogleChromeLabs/squoosh /app 

WORKDIR /app

RUN npm install --frozen-lockfile
RUN sed -i 's/static/static-build/' lib/move-output.js
RUN npm run build

# Final stage to serve the built application
FROM base AS builder
WORKDIR /app

RUN npm install -g serve

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=build /app/.tmp/build/static /app

USER nextjs

CMD ["npx", "serve", "."]