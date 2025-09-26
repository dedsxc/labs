FROM alpine:3.22.1@sha256:4bcff63911fcb4448bd4fdacec207030997caf25e9bea4045fa6c8c44de311d1 AS builder

# Install dependencies and download the ROCm version of Ollama
# https://github.com/ollama/ollama/blob/main/docs/linux.md#manual-install
RUN apk update && apk add curl
RUN curl -L https://ollama.com/download/ollama-linux-amd64-rocm.tgz -o ollama-linux-amd64-rocm.tgz 
RUN tar -C /tmp -xzf ollama-linux-amd64-rocm.tgz

FROM ollama/ollama:0.12.3@sha256:b4928458d13e61a03f718e61f93f0cf029ec5a50f083289185e40bbb43804766

RUN useradd --create-home ollama

COPY --from=builder /tmp/lib/ollama/rocm /lib/ollama/rocm

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]