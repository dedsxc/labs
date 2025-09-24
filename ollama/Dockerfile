FROM ollama/ollama:0.12.1@sha256:5aed793ab336d1aac9b132f4b46fddfcfa13b8911def3d275937c8acbd1763e8

RUN useradd --create-home ollama

USER ollama 

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]