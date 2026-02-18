FROM ollama/ollama:0.16.2@sha256:0764cf55b4a33bcecca10f718394d097ef7d464b75669a14f0cd4ac1a8b9a0c5

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