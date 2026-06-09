FROM ollama/ollama:0.30.7@sha256:46399ef084d97b381955b5dc585c5d836dbe7ed3f79f170d1c04660fed511e3a

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]