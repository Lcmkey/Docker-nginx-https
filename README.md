# Nginx With docker

1. __Create a html file__

    ```html
    <!-- index.html -->
    <!DOCTYPE html>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>Docker nginx</title>
    </head>

    <body>
        Hello world!
    </body>

    </html>
    ```

&thinsp;

2. __Create config file__

    ```properties
    <!-- nginx.config -->
    server{
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  lou.com;
        root         /usr/share/nginx/html;
        index        index.html;
        charset utf-8;
        access_log /var/log/nginx/access_log;
        error_log /var/log/nginx/error_log;
    }
    ```

&thinsp;

3. __Create Docker file__

    ```docker
    <!-- Dockerfile -->
    FROM nginx

    COPY ./html/index.html /usr/share/nginx/html
    COPY config/nginx.conf /etc/nginx/conf.d/default.conf
    ```

    The File Structure will be like below:

    ```
    ├── conf
    │   └── nginx.conf
    ├── Dockerfile
    └── html
        └── index.html
    ```

&thinsp;

4. __Create Image__

        $ docker build . -t nginx-custom

&thinsp;

5. __Check Image build success__

        $ docker images

    output:
    ```
    REPOSITORY      TAG       IMAGE ID        CREATED           SIZE
    nginx_custom    latest    2b4aa0dfb84f    7 minutes ago     132MB

    ```

&thinsp;

6. __Run Image as container service__

        $ docker run --name nginx-custom -it -d -p 8080:80 nginx-custom

&thinsp;

7. __Check Container service that is running__

        $ docker ps

    output:
    ```
    CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                  PORTS                    NAMES
    8df1bab50847        nginx-custom        "/docker-entrypoint.…"   9 seconds ago       Up 8 seconds            0.0.0.0:8080->80/tcp     nginx-custom
    ```

&thinsp;

8. __Test the Service__

        $ curl http://localhost:8080

    output:
    ```html
    <!DOCTYPE html>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>Docker nginx</title>
    </head>

    <body>
        Hello world!
    </body>

    </html>
    ```

&thinsp;

9. __Remove Container && Images__

        $ docker rm nginx-custom
        $ docker rmi nginx-custom


10. __Clone config file from the docker container__

        $ docker cp nginx-custom:/etc/nginx .

11. __Stop container service__

        $ docker stop nginx-custom


12. __Re-create container service with config file__

        $ docker run --rm --name nginx-custom --volume "$PWD/html":/usr/share/nginx/html --volume "$PWD/nginx":/etc/nginx -p 127.0.0.2:8081:80 -d nginx-custom

13. __Stop container service__

    As step `11`

14. __Create Self-Signed Certs__

        $ sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout example.key -out example.crt

> Answer the quetions && input the Common Name to `127.0.0.2`


15. __Copy the certs to `nginx/certs`__

        $ make -p ./nginx/certs
        $ mv example.crt exmaple.key ./nginx/certs

16. __Change default conf file__

        $ nano nginx/conf.d/default.conf

    apple below content to file

    ```properties
    server {
        listen 443 ssl http2;
        server_name  localhost;

        ssl                      on;
        ssl_certificate          /etc/nginx/certs/example.crt;
        ssl_certificate_key      /etc/nginx/certs/example.key;

        ssl_session_timeout  5m;

        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2;
        ssl_prefer_server_ciphers   on;

        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
        }
    }
    ```
17. __Start Nginx container service__

        $ docker run --rm --name nginx-custom --volume "$PWD/html":/usr/share/nginx/html --volume "$PWD/nginx":/etc/nginx -p 127.0.0.2:8081:80 -p 127.0.0.2:8082:443 -d nginx-custom

18. __Testing__

        $ curl -k https://127.0.0.2:8082

    output:
    ```html
    <!DOCTYPE html>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>Docker nginx</title>
    </head>

    <body>
        Hello world!
    </body>

    </html>
    ```

19. ___Stop Service_

        $ docker stop nginx-custom

# Docker-compose steps

1. __Create docker-compose file__

    ```yml
    <!-- docker-compose.yml -->
    version: '3.1'

    services:
    nginx-custom:
        image: nginx
        container_name: nginx-custom
        restart: always
        ports:
        - 8081:80
        volumes:
        - ./html:/usr/share/nginx/html
    ```

2. __Run Nginx Container service__

        $ make up

3. __Create Config file__

        $ make create-conf

4. __Change docker-compose file content__

    ```yml
    <!-- docker-compose.yml -->
    version: '3.1'

    services:
    nginx-custom:
        image: nginx
        container_name: nginx-custom
        restart: always
        ports:
        - 127.0.0.2:8081:80
        - 127.0.0.2:8082:443
        volumes:
        - ./conf:/etc/nginx
        - ./html:/usr/share/nginx/html
    ```

5. __Create self-signed certs && move to config file__

        $ make create-certs

6. __restart the container service__

        $ make up

7. __Testing__

        $ curl curl -k https://127.0.0.2:8082

    output:
    ```html
    <!DOCTYPE html>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>Docker nginx</title>
    </head>

    <body>
        Hello world!
    </body>

    </html>
    ```

8. __Stop Service__

        $ make down