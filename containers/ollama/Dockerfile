FROM ollama/ollama:0.30.8@sha256:05b6fe5143ed006d6d4abd39bdd575f962a5822bdf81e6fbb5e6894eb984ab9c

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]