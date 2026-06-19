FROM ollama/ollama:0.30.10@sha256:bfc9c6d53cc6989aa5131a6fde6b162b2802d4d337657f3253b5f69579bddeee

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]