FROM ollama/ollama:0.20.5@sha256:662109db8037f17257cfc6e816289c0d4c9ae8a2a4ff760b653d8d410e234ba0

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]