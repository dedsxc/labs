FROM ollama/ollama:0.17.4@sha256:b165fa2700dc374f8d4f9e8314d81c7be75487c76eee2b46ef4b511a496b736c

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]