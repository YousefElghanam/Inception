FROM debian:stable-slim

WORKDIR /usr/local/app

RUN apt update
RUN apt -y install nginx openssl

COPY ./conf/default.conf /etc/nginx/sites-enabled/default

RUN mkdir -p /etc/nginx/ssl \
    && openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/jel-ghna.42.fr.key \
        -out /etc/nginx/ssl/jel-ghna.42.fr.crt \
        -subj "/CN=jel-ghna.42.fr" \
        -addext "subjectAltName=DNS:jel-ghna.42.fr"

CMD ["nginx", "-g", "daemon off;"]
