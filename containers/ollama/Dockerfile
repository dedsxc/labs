FROM ollama/ollama:0.23.0@sha256:5600a652d1081050f398152127c584222546354491f27fe47ccbc6351bc870bd

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]