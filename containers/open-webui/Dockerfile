FROM ghcr.io/open-webui/open-webui:v0.11.4@sha256:9591b13f13843c7721c2b8eaf7382846c81b3ffe126526d1888d1fed50c6a33f

RUN useradd -m user
RUN chown user:user -R /app/backend
USER user

CMD [ "bash", "start.sh"]
