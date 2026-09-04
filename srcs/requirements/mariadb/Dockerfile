FROM debian:stable-slim

WORKDIR /usr/local/app

RUN apt update
RUN apt -y install mariadb-server

RUN rm -rf /var/lib/mysql/*
RUN sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

