FROM ollama/ollama:0.12.2@sha256:1b80cecb262ee3be70474130aaff1e4949dab741c74b94e819d3f2a2ba520f29

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]