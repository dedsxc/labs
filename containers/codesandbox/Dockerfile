# --- Serve with nginx ---
FROM nginx:1.31-alpine-perl@sha256:7725b425b6df0a2222051ad1201cdba8f7b7cc0b6351b77f82815410e602afc7

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
