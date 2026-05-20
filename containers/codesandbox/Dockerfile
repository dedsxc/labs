# --- Serve with nginx ---
FROM nginx:1.30-alpine-perl@sha256:4b98ea12a4298a587d91f46759f8d2695ac6e4e8442b857a6ca36963c0dd7df3

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
