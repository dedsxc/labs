FROM ollama/ollama:0.12.8@sha256:bf65a7c25eb4561131ccbecd81991a5fdb37d8970958a3877533358ff28e0620

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]