FROM ollama/ollama:0.11.11@sha256:24d41d792306fc3221de215bb6f225faf981712d1f38083d8c61301dfa2b69b3

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]