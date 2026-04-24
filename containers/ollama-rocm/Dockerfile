FROM ollama/ollama:0.21.2@sha256:2038a264392af4d21f7f14e1568e8dd9aa0f2bd0f31d7d9a59a8cca1e9829663

RUN useradd --create-home ollama \
    && apt-get update && apt-get install -y --no-install-recommends curl zstd \
    && curl -L https://ollama.com/download/ollama-linux-amd64-rocm.tar.zst \
    | zstd -d \
    | tar -xf - -C / \
    && apt-get purge -y --auto-remove curl zstd \
    && rm -rf /var/lib/apt/lists/*

USER ollama

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]