FROM debian:stable-slim

WORKDIR /usr/local/app

RUN apt update
RUN apt -y install wordpress php-fpm
RUN apt -y install curl mariadb-client

# install wp
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

# make it listen on 9000
RUN sed -i 's|^listen = .*|listen = 9000|' /etc/php/8.4/fpm/pool.d/www.conf

COPY ./tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

