FROM ollama/ollama:0.20.7@sha256:487324a9312240e3e122446f351b1f1e3f68d884ef854c246db2e08792440d94

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