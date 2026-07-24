# --- Serve with nginx ---
FROM nginx:1.31-alpine-perl@sha256:5a1b9b3dd82ce370617a2ad9825c03b354415b2f74f856a54273a5ec6052cb38

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
