# --- Serve with nginx ---
FROM nginx:1.31-alpine-perl@sha256:ff2900647084aa935083cb7c840ecd2d3fc27db04665fa000a84af88cf300cb4

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
