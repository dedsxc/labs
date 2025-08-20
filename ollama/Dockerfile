FROM ollama/ollama:0.11.5@sha256:802596626817a4f24ae26c7e3e3e0ba368cfb93e3945fc176bb714000abcbb4d

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]