# --- Serve with nginx ---
FROM nginx:1.30-alpine-perl@sha256:54d05684e0dccb53f2b373ec0a3c652f1e06e2b3705652f58be67e54b2ba26b7

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
