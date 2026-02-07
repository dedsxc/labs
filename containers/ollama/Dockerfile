FROM ollama/ollama:0.15.6@sha256:5f7a20da9b4d42d1909b4693f90942135bcabc335ee42d529c0d143c44a92311

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]