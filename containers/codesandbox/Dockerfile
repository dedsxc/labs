# --- Serve with nginx ---
FROM nginx:1.31-alpine-perl@sha256:9c0cd54a2f03e1c7d8e9973ac60f112dd988d04049a6fee49fbd994ce9f39057

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
