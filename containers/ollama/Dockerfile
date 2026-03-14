FROM ollama/ollama:0.18.0@sha256:e23e6499890325d31f3454cdc83f7a613a2423c8a9e167bbafea0b0e3c27d7c6

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]