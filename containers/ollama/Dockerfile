FROM ollama/ollama:0.14.0@sha256:4d1c3ff8badca57327c1eb35e1842f7a28f3578ef40c8488a58854e083f53a1b

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]