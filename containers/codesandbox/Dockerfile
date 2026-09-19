# --- Serve with nginx ---
FROM nginx:1.31-alpine-perl@sha256:5244209fc70b95cfacf5c581abc40e436f684a41e6bb2515472a863d60ce088a

COPY ./www /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
