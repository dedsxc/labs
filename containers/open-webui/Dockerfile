FROM ghcr.io/open-webui/open-webui:0.6.40@sha256:c13ea534284fa52b282fb2780ffc34a42cc66495234789be8327a9f3d35b53dd

RUN useradd -m user
RUN chown user:user -R /app/backend
USER user

CMD [ "bash", "start.sh"]
