FROM ghcr.io/open-webui/open-webui:v0.9.6@sha256:90eae5b419e40b4c3dd684582b2c83440b36f9ae2f6532c09639b2ba4ee65158

RUN useradd -m user
RUN chown user:user -R /app/backend
USER user

CMD [ "bash", "start.sh"]
