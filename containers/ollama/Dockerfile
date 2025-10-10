FROM ollama/ollama:0.12.4@sha256:e2f0af4a865c61b580cc17a7e2bda3c82083046b74c5a5402ce32a0d84454f9b

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]