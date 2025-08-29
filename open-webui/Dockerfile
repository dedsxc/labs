FROM ghcr.io/open-webui/open-webui:main@sha256:06f4cae7f8873ebcee7952d9993e457c1b083c6bea67b10bc356db7ac71c28e2

RUN useradd -m user
RUN chown user:user -R /app/backend
USER user

CMD [ "bash", "start.sh"]