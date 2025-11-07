FROM ghcr.io/open-webui/open-webui:v0.6.36@sha256:dfe43b30a5474164b1a81e1cce298a6769bb22144f74df556beefee4ccca5394

RUN useradd -m user
RUN chown user:user -R /app/backend
USER user

CMD [ "bash", "start.sh"]
