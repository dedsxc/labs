# --- Serve with nginx ---
FROM nginx:1.31-alpine-perl@sha256:af0b872730bb5b4fb27aab90acf02d20cbc3d482e69fd846e0234a1b90602ccd

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
