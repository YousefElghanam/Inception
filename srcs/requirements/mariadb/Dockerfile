FROM debian:stable-slim

WORKDIR /usr/local/app

RUN apt update
RUN apt -y install mariadb-server
RUN rm -rf /var/lib/mysql/*

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

