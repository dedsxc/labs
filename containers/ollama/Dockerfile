FROM ollama/ollama:0.16.1@sha256:dca1224ecd799f764b21b8d74a17afdc00505ecce93e7b55530d124115b42260

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]