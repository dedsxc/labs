FROM rocm/vllm:rocm7.0.0_vllm_0.11.2_20251210@sha256:e7f02dd2ce3824959658bc0391296f6158638e3ebce164f6c019c4eca8150ec7

RUN useradd vllm

USER vllm

ENTRYPOINT ["/bin/vllm"]
CMD ["serve"]