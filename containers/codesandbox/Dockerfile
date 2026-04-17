# --- Serve with nginx ---
FROM nginx:1.30-alpine-perl@sha256:7282bc283a02771eadc184f7c033fcb36f01eba15c3fd6554a57e8bb0ae8d9b4

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
