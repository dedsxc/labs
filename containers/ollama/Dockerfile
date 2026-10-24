FROM ollama/ollama:0.40.10@sha256:4c5b27871a3239a717048f9b93057680a51b60c8119a7016aebb57f938e25e35

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]