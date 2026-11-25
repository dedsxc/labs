FROM ollama/ollama:0.40.18@sha256:1cabd20e1762a7a8444bf4a7110b346d923cd77ab6c97c984434140638c913ec

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]