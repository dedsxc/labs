FROM ollama/ollama:0.20.3@sha256:87d71eb588a28c747094ca5d011392a3790f6ea9bd9c87594780ad7c65cc7ed1

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]