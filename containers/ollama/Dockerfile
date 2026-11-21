FROM ollama/ollama:0.40.17@sha256:ccc42bcd3d5fcf7ab0d532b300382154e1a4da56fc666bdb313b78ebdd912754

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]