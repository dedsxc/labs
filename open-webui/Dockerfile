FROM ghcr.io/open-webui/open-webui:main@sha256:2964a606181b1db2ce45deff111fe6438f331058154a6ea5e4b01a3070a6630b

RUN useradd -m user
RUN chown user:user -R /app/backend
USER user

CMD [ "bash", "start.sh"]