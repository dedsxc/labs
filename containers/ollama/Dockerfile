FROM ollama/ollama:0.12.7@sha256:de29cf776a66aae03ace78d7b09660eebc4b0b4d547a67a04740353a171722f0

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]