FROM alpine:3.23.2@sha256:865b95f46d98cf867a156fe4a135ad3fe50d2056aa3f25ed31662dff6da4eb62 AS builder

# Install dependencies and download the ROCm version of Ollama
# https://github.com/ollama/ollama/blob/main/docs/linux.md#manual-install
RUN apk update && apk add curl zstd
RUN curl -L https://ollama.com/download/ollama-linux-amd64-rocm.tar.zst \
    | zstd -d \
    | tar -xf - -C /tmp/

FROM ollama/ollama:0.14.0@sha256:4d1c3ff8badca57327c1eb35e1842f7a28f3578ef40c8488a58854e083f53a1b

RUN useradd --create-home ollama

COPY --from=builder /tmp/lib/ollama/rocm /lib/ollama/rocm

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]