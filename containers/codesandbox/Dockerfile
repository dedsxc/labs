# --- Serve with nginx ---
FROM nginx:1.31-alpine-perl@sha256:3eac5f19b65a60271c60c3c0241d4e6a38531201e9bc2398ac431e09355f2633

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
