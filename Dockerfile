FROM nginx

COPY ./html/index.html /usr/share/nginx/html

RUN apt update
RUN apt install nano