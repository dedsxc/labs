FROM ghcr.io/open-webui/open-webui:v0.8.1@sha256:882a4aab2cb573feeb681f7f800ac5ada4751d03981cc324718757c74ecc1c70

RUN useradd -m user
RUN chown user:user -R /app/backend
USER user

CMD [ "bash", "start.sh"]
