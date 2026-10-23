# --- Serve with nginx ---
FROM nginx:1.31-alpine-perl@sha256:de093330a48416982a0dd2503996f56127d317829889d5787ab1f4208343550a

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
