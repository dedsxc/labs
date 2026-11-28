FROM ollama/ollama:0.40.19@sha256:7e8c7ba387b11b09dcce1eff1118b1ab433564ed263434a7730c209f2ee346f4

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]