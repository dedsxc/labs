FROM ollama/ollama:0.15.4@sha256:37ef34d78a6f4563a11cbbb336bbaa75f01eb19671d639973f98baa58f11a5ed

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]