FROM php:7.4-fpm-buster

#Env Path
ENV HOME="/root"
ENV PATH="$HOME/.composer/vendor/bin:${PATH}"
ENV PHP_EXTENSION_XDEBUG_ENABLE=0
ENV PHP_EXTENSION_XDEBUG_PORT=9000
ENV PHP_EXTENSION_XDEBUG_IDE_KEY="PHPSTORM"

#Copy Certs for SWGS
COPY certs/* /usr/local/share/ca-certificates/
RUN update-ca-certificates

#Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --filename=composer --install-dir=/usr/local/bin && \
    php -r "unlink('composer-setup.php');"

#Basic Libaries
RUN apt-get update && apt-get install apt-transport-https wget gnupg -y

#Run Install Google Chrome for Broswer Testing
RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - &&\
     echo "deb [arch=amd64]  http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list &&\
     apt-get -y update &&\
     apt-get -y install google-chrome-stable

#UnixODBC Manually Install Debian Strech doesn't support the latest version and is causing issues with connection pooling
# hense why this is a manual install
RUN  cd ~ && wget ftp://ftp.unixodbc.org/pub/unixODBC/unixODBC-2.3.7.tar.gz && \
     tar xvzf unixODBC-2.3.7.tar.gz && cd unixODBC-2.3.7 && ./configure && make && make install && \
     cd ~ && rm unixODBC-2.3.7.tar.gz && rm -rf unixODBC-2.3.7

# Install MSSQL Repos
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list

# Install Required Libs
# When you upgrade the sql server driver also update the odbcinst.ini drive to keep the connection pooling.
# If not the performance will be degrated to a single connection.
RUN apt-get update && ACCEPT_EULA=Y apt-get -y install libzip-dev unzip apt-utils locales zlib1g-dev libldap2-dev libpng-dev
RUN ACCEPT_EULA=Y apt-get -y install msodbcsql17 && \
    ACCEPT_EULA=Y apt-get -y install mssql-tools


#Pecl Install
RUN docker-php-ext-install zip && \
    docker-php-ext-enable zip && \
    pecl install redis-5.1.1 && \
    docker-php-ext-enable redis && \
    pecl install pdo_sqlsrv-5.8.0 && \
    docker-php-ext-enable pdo_sqlsrv && \
    pecl install sqlsrv-5.8.0 && \
    docker-php-ext-enable sqlsrv && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap && \
    docker-php-ext-install opcache && \
    pecl install xdebug && \
    docker-php-ext-enable xdebug

#SQL Server Post Install
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

#Fix for SSL 1.1.1+ https://owendavies.net/articles/docker-php-mssql-error/
RUN sed -i -E 's/(CipherString\s*=\s*DEFAULT@SECLEVEL=)2/\11/' /etc/ssl/openssl.cnf

#Setup MSSQL
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc && \
    echo /bin/bash -c "source ~/.bashrc"

#Set Working Directory
WORKDIR /var/www/

#Copy Files
COPY php/php/php.ini /usr/local/etc/php/php.ini
COPY php/odbcinst.ini /usr/local/etc/odbcinst.ini
COPY php/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY php/php-fpm.conf /usr/local/etc/php-fpm.conf

#xdebug
RUN mkdir -p /tmp/xdebug_log/ &&\
    touch /tmp/xdebug_log/xdebug.log &&\
    chmod 777 /tmp/xdebug_log/xdebug.log