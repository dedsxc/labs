FROM ollama/ollama:0.30.6@sha256:fbaaecc6c632a73c2b4ca25ef52dbee0b68d07783fcb850f916404c004040f90

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]