FROM ollama/ollama:0.14.1@sha256:ab381bda4be8e04790e32551fac37f209fe0bb12ab49ba4b7c32d0f0800cf4c3

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]