# --- Serve with nginx ---
FROM nginx:1.31-alpine-perl@sha256:0f5f6ada969490953b1514eebdd8ba7514a32e11f33c6675e0c6a45a2185562a

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
