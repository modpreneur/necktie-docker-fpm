FROM php:7.1-fpm-alpine

MAINTAINER Martin Kolek <kolek@modpreneur.com>

#git from alpine 3.5 have issue
#RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.5/main" > /etc/apk/repositories \
#    && echo "http://dl-cdn.alpinelinux.org/alpine/v3.5/community" >> /etc/apk/repositories


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
    make \
    #for gd extension
    libpng-dev \
    #cron
    busybox-suid


RUN docker-php-ext-configure bcmath \
    && docker-php-ext-install curl json mbstring opcache zip bz2 mcrypt pdo_mysql pdo_pgsql bcmath gd


RUN pecl install -o -f apcu-5.1.8 apcu_bc-beta \
    && echo "extension=apcu.so" > /usr/local/etc/php/conf.d/apcu.ini \
    && echo "extension=apc.so" >> /usr/local/etc/php/conf.d/apcu.ini


RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/bin/composer \
    && touch /usr/local/etc/php/php.ini \
    && echo "memory_limit = 2048M" >> /usr/local/etc/php/php.ini


#php-fpm listen on port 9090 becase of xdebux use port 9000 and supervisor use port 9001 and 9002
RUN echo "listen = [::]:9090" >> /usr/local/etc/php-fpm.conf


# cron
RUN rm -rf /etc/crontabs/www-data \
&& cp /etc/crontabs/root /etc/crontabs/www-data \
&& truncate /etc/crontabs/www-data -s 0



WORKDIR /var/app

#RUN apk del \
#    g++ \
#    autoconf \
#    make \
#    wget \
#    && rm -rf /var/cache/apk/*



RUN echo "modpreneur/necktie-fpm:0.7" >> /home/versions