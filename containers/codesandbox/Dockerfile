# --- Serve with nginx ---
FROM nginx:1.31-alpine-perl@sha256:b4f40fc790074a4af0d6fc81923a30459910d6f01efc048246ef288b14654354

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
