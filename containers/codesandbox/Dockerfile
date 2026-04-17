# --- Serve with nginx ---
FROM nginx:1.29-alpine-perl@sha256:52311df06b395b41b19aac3838d789f2168134a35ca9701c199c87ba10b1e745

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
