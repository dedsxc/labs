FROM ollama/ollama:0.15.1@sha256:e0ae5354a9e4c85160df4698a45ae360cd0c12ef90e484b12fc870c28f491892

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]