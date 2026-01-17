FROM ollama/ollama:0.14.2@sha256:44893537fcc6f100b70ceb7f5c9fd8f787ba58f9f8ce73bf4a48a5b05fd8c422

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]