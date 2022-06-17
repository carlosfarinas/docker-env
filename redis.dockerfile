FROM redis:5

COPY certs/* /usr/local/share/ca-certificates/

RUN apt-get update && \
    apt-get install apt-utils openssl ca-certificates curl gnupg apt-transport-https -y && \
    update-ca-certificates

EXPOSE 6379