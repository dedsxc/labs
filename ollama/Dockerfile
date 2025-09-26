FROM ollama/ollama:0.12.3@sha256:b4928458d13e61a03f718e61f93f0cf029ec5a50f083289185e40bbb43804766

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]