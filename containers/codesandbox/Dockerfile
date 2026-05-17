# --- Serve with nginx ---
FROM nginx:1.30-alpine-perl@sha256:4d9de1b520945f3c9371dabed9e54dca581da1a2097bbb2d9b9c9462ba53c8be

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
