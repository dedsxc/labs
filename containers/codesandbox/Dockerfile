# --- Serve with nginx ---
FROM nginx:1.31-alpine-perl@sha256:b3b337e1ef5b1bc8253dec68bc4522d9027920666a428bf51a022ceb7e3396bc

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
