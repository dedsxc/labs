FROM ollama/ollama:0.18.3@sha256:e305a7b6529c3deada679f07f98ac3222ce668bfc970062f83a5e4e7e15b8f6d

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]