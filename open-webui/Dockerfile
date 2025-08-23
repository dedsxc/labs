FROM ghcr.io/open-webui/open-webui:main@sha256:74a5ee5c453e628c2bcd33a41dfe4dcf62d187fedf4867d6b8a087178cd88aa6

RUN useradd -m user
RUN chown user:user -R /app/backend
USER user

CMD [ "bash", "start.sh"]