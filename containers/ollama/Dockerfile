FROM ollama/ollama:0.16.3@sha256:63f052826604a28a83795df1a66d9e364410c0b8d1357a62a885c62cef05cdbb

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]