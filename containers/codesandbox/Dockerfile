# --- Serve with nginx ---
FROM nginx:1.31-alpine-perl@sha256:f810f70445b5fa6738d0897e0142e7a52d487304907e62fe63c68666101e6e4e

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
