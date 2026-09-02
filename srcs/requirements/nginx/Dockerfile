FROM debian:stable-slim

WORKDIR /usr/local/app

RUN apt update
#RUN apt -y install tini
RUN apt -y install nginx openssl

#ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["nginx", "-g", "daemon off;"]
