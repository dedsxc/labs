FROM ollama/ollama:0.20.2@sha256:0455f166da85b1d07f694c33ba09278ca649603c0611ba8e46272b16eed7fccd

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