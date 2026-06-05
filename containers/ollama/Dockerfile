FROM ollama/ollama:0.30.5@sha256:72c60eb9e115e24078864c00274dc067fff2217b105918409856031cca7a7e92

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]