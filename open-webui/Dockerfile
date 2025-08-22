FROM ghcr.io/open-webui/open-webui:main@sha256:b101231569b46b326f8badfde103aa570fb97d962140a5ef08ee2603d6458be7

RUN useradd -m user
RUN chown user:user -R /app/backend
USER user

CMD [ "bash", "start.sh"]