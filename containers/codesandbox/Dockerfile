# --- Serve with nginx ---
FROM nginx:1.30-alpine-perl@sha256:1c87b22b1cadb8dc0b00370d9098a8bfe872c7ddd520a8f0df154ab6b1aad375

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
