# --- Serve with nginx ---
FROM nginx:1.31-alpine-perl@sha256:9f53ce4cf1640b14c74a6523f743bf6d2ee6115ea59a6f1fac61cfb8aaf1ed72

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
