FROM ollama/ollama:0.22.0@sha256:05ab093b257a54318fba39293f1640d53b507d1edec8fa6ca2d3e1817c02e53b

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]