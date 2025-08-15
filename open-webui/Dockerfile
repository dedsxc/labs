FROM ghcr.io/open-webui/open-webui:main@sha256:a439e8bcd23a8cc0e9ab742b03f1baecb829281476357b99226e13233e663508

RUN useradd -m user
RUN chown user:user -R /app/backend
USER user

CMD [ "bash", "start.sh"]