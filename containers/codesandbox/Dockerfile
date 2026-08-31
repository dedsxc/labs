# --- Serve with nginx ---
FROM nginx:1.31-alpine-perl@sha256:f1aec5de9d214ab7dad6b67c6665ee9eaa55ac890c710700216804d8b4829802

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
