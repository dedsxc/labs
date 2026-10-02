# --- Serve with nginx ---
FROM nginx:1.31-alpine-perl@sha256:615c74c43b5d72851941e0f522afd72c3c8ee34217bfa1ad2258f21cb369a0bc

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
