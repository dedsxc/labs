# --- Serve with nginx ---
FROM nginx:1.29-alpine-perl@sha256:0b8b38a871c9dbaebacf9da373e92196b625e3e19edea5084bc32bbd74f67f1c

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
