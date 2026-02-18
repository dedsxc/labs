FROM ollama/ollama:0.16.2@sha256:0764cf55b4a33bcecca10f718394d097ef7d464b75669a14f0cd4ac1a8b9a0c5

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]