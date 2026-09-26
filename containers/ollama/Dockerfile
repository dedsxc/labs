FROM ollama/ollama:0.34.4@sha256:8262851b2846b87c649eddf3e76beb270c52f4d1bc94559f47efde16b0841551

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]