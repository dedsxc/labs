FROM node:16-bookworm AS builder
WORKDIR /app

RUN apt update && apt install -y chromium zstd
# Clone & install
RUN git clone --depth 1 https://github.com/codesandbox/codesandbox-client.git .
RUN yarn install

# Build
RUN yarn build:deps
RUN yarn build:sandpack

# --- Serve with nginx ---
FROM nginx:1.29-alpine-perl@sha256:bda8aad848e2b8a13fcbb887bf1bb3aba9d1a6c4f87731ee97df1a85ade999e1

COPY --from=builder /app/www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
