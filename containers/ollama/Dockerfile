FROM ollama/ollama:0.15.3@sha256:3970c9b21fc1286d2958dd33f9a4774d70a9b63d596c61ad0ed5b5dd28291dbe

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]