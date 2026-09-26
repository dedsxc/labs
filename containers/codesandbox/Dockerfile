# --- Serve with nginx ---
FROM nginx:1.31-alpine-perl@sha256:9797b3f50368cceee485299cba8ee7139a164076b1417f5a2259fdc8072d1b5c

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
