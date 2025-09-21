FROM ghcr.io/open-webui/open-webui:main@sha256:05aaa81eb4094038a16f0ae056342e3515d1912a30e41b828bfd3731fbe36a6c

RUN useradd -m user
RUN chown user:user -R /app/backend
USER user

CMD [ "bash", "start.sh"]