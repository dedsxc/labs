# --- Serve with nginx ---
FROM nginx:1.29-alpine-perl@sha256:bda8aad848e2b8a13fcbb887bf1bb3aba9d1a6c4f87731ee97df1a85ade999e1

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
