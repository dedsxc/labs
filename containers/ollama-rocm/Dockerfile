FROM alpine:3.22.2@sha256:4b7ce07002c69e8f3d704a9c5d6fd3053be500b7f1c69fc0d80990c2ad8dd412 AS builder

# Install dependencies and download the ROCm version of Ollama
# https://github.com/ollama/ollama/blob/main/docs/linux.md#manual-install
RUN apk update && apk add curl
RUN curl -L https://ollama.com/download/ollama-linux-amd64-rocm.tgz -o ollama-linux-amd64-rocm.tgz 
RUN tar -C /tmp -xzf ollama-linux-amd64-rocm.tgz

FROM ollama/ollama:0.12.11@sha256:3d8a05e3432d50ea57594fabe971e46cc8fe963a0f9f8c40400bd56cd5388e47

RUN useradd --create-home ollama

COPY --from=builder /tmp/lib/ollama/rocm /lib/ollama/rocm

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]