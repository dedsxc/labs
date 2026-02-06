FROM ollama/ollama:0.15.5@sha256:ea37dcbf693248c80796654500fccf1e12f55da20ec7c78c30870a9a227c4cdd

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]