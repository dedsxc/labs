FROM ghcr.io/open-webui/open-webui:v0.11.2@sha256:77ff490214a4b2699b309aa8d39bf4b42eca05f62d2742ef669ff846fcd10355

RUN useradd -m user
RUN chown user:user -R /app/backend
USER user

CMD [ "bash", "start.sh"]
