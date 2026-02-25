FROM ghcr.io/open-webui/open-webui:v0.8.5@sha256:2deb90b0423473d8f97febced2e62b8fd898aa3eb61877bb3aa336370214c258

RUN useradd -m user
RUN chown user:user -R /app/backend
USER user

CMD [ "bash", "start.sh"]
