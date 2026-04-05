FROM ollama/ollama:0.20.2@sha256:0455f166da85b1d07f694c33ba09278ca649603c0611ba8e46272b16eed7fccd

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]