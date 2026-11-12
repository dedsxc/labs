# --- Serve with nginx ---
FROM nginx:1.31-alpine-perl@sha256:97ac5292116888605dfa67cca0dc2fe13aad0e00b9890ef834680b6e0a4ef2c5

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
