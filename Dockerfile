FROM php:7.1-fpm-alpine

MAINTAINER Martin Kolek <kolek@modpreneur.com>

RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.5/main" > /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/v3.5/community" >> /etc/apk/repositories


# install packages, apcu, bcmath for rabbit, composer with plugin for paraller install, clean apache sites
RUN apk add --update \
    curl-dev \
    git \
    postgresql-dev \
    zlib-dev \
    bzip2-dev \
    wget \
    libmcrypt-dev \
    supervisor\
    #for pecl
    g++ \
    autoconf \
    make


RUN docker-php-ext-configure bcmath \
    && docker-php-ext-install curl json mbstring opcache zip bz2 mcrypt pdo_mysql pdo_pgsql bcmath

RUN pecl install -o -f apcu-5.1.7 apcu_bc-beta \
    && echo "extension=apcu.so" > /usr/local/etc/php/conf.d/apcu.ini \
    && echo "extension=apc.so" >> /usr/local/etc/php/conf.d/apcu.ini

RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/bin/composer \
    && touch /usr/local/etc/php/php.ini \
    && echo "memory_limit = 2048M" >> /usr/local/etc/php/php.ini


COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/supervisor-manager.sh /opt/supervisor-manager.sh


#php-fpm lisen on port 9001 becase of xdebux
RUN echo "listen = [::]:9001" >> /usr/local/etc/php-fpm.conf


WORKDIR /var/app

#todo smazat g++ autoconf make a další věci co tu nepotřebuju
#dát sem uložení verze do soubory