FROM ollama/ollama:0.13.3@sha256:6c76395793f40a5e78f120e880ca82c67e39eb908ad90eee8ce755535529d0ec

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]