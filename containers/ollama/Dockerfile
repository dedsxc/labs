FROM ollama/ollama:0.20.7@sha256:487324a9312240e3e122446f351b1f1e3f68d884ef854c246db2e08792440d94

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]