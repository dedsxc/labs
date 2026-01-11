FROM ghcr.io/open-webui/open-webui:0.7.2@sha256:16d9a3615b45f14a0c89f7ad7a3bf151f923ed32c2e68f9204eb17d1ce40774b

RUN useradd -m user
RUN chown user:user -R /app/backend
USER user

CMD [ "bash", "start.sh"]
