FROM ghcr.io/open-webui/open-webui:main@sha256:6411dd62178b3d5fbd26bd953b12c03e74ede96875aa96c394513628ba842cc1

RUN useradd -m user
RUN chown user:user -R /app/backend
USER user

CMD [ "bash", "start.sh"]