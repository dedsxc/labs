FROM ghcr.io/open-webui/open-webui:main@sha256:2e78a2f9f6f62173ae28d2203f3c9bcdadc614023380ebbe903ea9fab772535e

RUN useradd -m user
RUN chown user:user -R /app/backend
USER user

CMD [ "bash", "start.sh"]