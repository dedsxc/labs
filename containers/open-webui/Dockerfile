FROM ghcr.io/open-webui/open-webui:v0.9.2@sha256:a7e4796ae894d1e2a0c1824860ade472f35c507608a01c3581377b5c19b0ed49

RUN useradd -m user
RUN chown user:user -R /app/backend
USER user

CMD [ "bash", "start.sh"]
