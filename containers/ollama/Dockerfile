FROM ollama/ollama:0.15.2@sha256:76d0c003b27db65170e88ab319ff19c9bcee41ecb8177c52ab06921dfa13abdf

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]