FROM ollama/ollama:0.13.0@sha256:d4188c1dfa870386a14e299976aed96daeb83876b69e1a852c9d09ea76463b9f

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]