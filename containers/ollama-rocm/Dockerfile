FROM ollama/ollama:0.32.6@sha256:b88c73ace3e115f8ec53dc8761ae1c0aabfa675406e3681786b98757ce050f42

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