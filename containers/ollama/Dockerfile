FROM ollama/ollama:0.22.1@sha256:3ca37ec2b9cb6341b62554074205c616778fe98abcf9e4fc50361b79a07407ae

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]