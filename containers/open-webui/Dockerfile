FROM ghcr.io/open-webui/open-webui:main@sha256:d6ab9bce3030f5b58e59144a7db9fe3012b39c94d27bc2979e98e6d6dc2161da

RUN useradd -m user
RUN chown user:user -R /app/backend
USER user

CMD [ "bash", "start.sh"]