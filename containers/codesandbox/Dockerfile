# --- Serve with nginx ---
FROM nginx:1.29-alpine-perl@sha256:24f1c0620ea250726fd6bf754a174da4fac5208fcf0771c9b82c54857244e770

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
