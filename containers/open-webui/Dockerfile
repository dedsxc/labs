FROM ghcr.io/open-webui/open-webui:v0.8.10@sha256:ee057955040ce91e3e787e4b7978c9c23e828972c68d01d787ed40f9a307df9f

RUN useradd -m user
RUN chown user:user -R /app/backend
USER user

CMD [ "bash", "start.sh"]
