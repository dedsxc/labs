FROM ollama/ollama:0.11.9@sha256:d8f430f5b760c8c2f93d6fc12d91fa02dfb1ec3d55865483adb9b76c43b0e980

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]