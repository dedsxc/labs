FROM alpine:3.23.0@sha256:51183f2cfa6320055da30872f211093f9ff1d3cf06f39a0bdb212314c5dc7375 AS builder

# Install dependencies and download the ROCm version of Ollama
# https://github.com/ollama/ollama/blob/main/docs/linux.md#manual-install
RUN apk update && apk add curl
RUN curl -L https://ollama.com/download/ollama-linux-amd64-rocm.tgz -o ollama-linux-amd64-rocm.tgz 
RUN tar -C /tmp -xzf ollama-linux-amd64-rocm.tgz

FROM ollama/ollama:0.13.1@sha256:8850b8b33936b9fb246e7b3e02849941f1151ea847e5fb15511f17de9589aea1

RUN useradd --create-home ollama

COPY --from=builder /tmp/lib/ollama/rocm /lib/ollama/rocm

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]