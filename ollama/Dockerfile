FROM ollama/ollama:0.11.8@sha256:03eaa1581455ba16e7c954d799e4f44996b60ae668261acd00a0e80a241ed720

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]