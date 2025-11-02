FROM ollama/ollama:0.12.9@sha256:889ae74bdb4aa541044574d3e5e5dedde3c682c8b7918b6792aa031e7dfc8f06

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]