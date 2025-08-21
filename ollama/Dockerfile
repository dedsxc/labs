FROM ollama/ollama:0.11.6@sha256:1868fd51253099b8f48b89b981e5d8ba23e4db161a501b86e29593071c1c069b

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]