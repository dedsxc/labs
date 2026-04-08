# --- Serve with nginx ---
FROM nginx:1.29-alpine-perl@sha256:3ed2d636d93ba3ae481e6ace1b64e97044ec9d27de13781f7a7bc9cc6719524e

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
