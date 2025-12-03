FROM ghcr.io/open-webui/open-webui:0.6.41@sha256:3e07bcede92e97cc3e741de095045a8b5d20bc257ecdb713bd2a47f68e9dff72

RUN useradd -m user
RUN chown user:user -R /app/backend
USER user

CMD [ "bash", "start.sh"]
