FROM ollama/ollama:0.11.7@sha256:c76340da9ed9906b01ed5462ca966b608de93a76c1fbc01123d07034a99f699b

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]