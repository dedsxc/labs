FROM ollama/ollama:0.21.1@sha256:cd33c5656285ca365c9c5495fe0240a70aef642088c6427c461fd54b62f80ffb

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]