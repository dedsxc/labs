FROM ghcr.io/open-webui/open-webui:v0.12.5@sha256:03443b8de6b617da9d900edd09b4bf1cb0ddbfdcba6afb42c548336a0b821ded

RUN useradd -m user
RUN chown user:user -R /app/backend
USER user

CMD [ "bash", "start.sh"]
