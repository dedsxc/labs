FROM ollama/ollama:0.14.3@sha256:a7471e7e503643d06767053fa4c825eaa7cafb1586f7256ce29080bcbf57bf5c

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]