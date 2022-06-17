FROM nginx:1.17

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/fastcgi_params /etc/nginx/fastcgi_params
COPY nginx/mime.types /etc/nginx/mime.types
COPY certs/* /usr/local/share/ca-certificates/

RUN apt-get update && \
    apt-get install apt-utils openssl ca-certificates curl gnupg apt-transport-https libpng-dev gcc make g++ -y && \
    update-ca-certificates

RUN mkdir /etc/nginx/logs
RUN touch /etc/nginx/logs/static.log

RUN mkdir /tmp/nginx

RUN rm -f /etc/nginx/conf.d/*
ADD nginx/*.site.conf /etc/nginx/conf.d/

#Install NPM
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash && \
    apt-get install -y nodejs

#Yarn Install
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - &&\
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list &&\
    apt-get update && apt-get install yarn

WORKDIR /var/www/

#Install the css/javascript scripts
RUN yarn config set strict-ssl false

EXPOSE 80 443