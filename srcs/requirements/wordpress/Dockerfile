FROM debian:stable-slim

WORKDIR /usr/local/app

RUN apt update
#RUN apt -y install tini
RUN apt -y install wordpress php-fpm

RUN sed -i 's|^listen = .*|listen = 9000|' /etc/php/8.4/fpm/pool.d/www.conf

#ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["php-fpm8.4", "-F"]

