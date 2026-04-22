FROM ghcr.io/open-webui/open-webui:v0.9.1@sha256:03d2b006989f0fe6559391a0c5d4ccac12688d7813d23cb4de86e5cc0ab22978

RUN useradd -m user
RUN chown user:user -R /app/backend
USER user

CMD [ "bash", "start.sh"]
