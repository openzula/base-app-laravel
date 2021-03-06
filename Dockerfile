FROM php:7.2-fpm
LABEL maintainer="alex@openzula.org"

EXPOSE 9000
WORKDIR /var/www

RUN apt-get update

## Healthcheck
RUN apt-get install -y libfcgi-bin

RUN echo 'pm.status_path = /oz-health-status' >> /usr/local/etc/php-fpm.d/zz-docker.conf
RUN echo 'ping.path = /oz-health-ping' >> /usr/local/etc/php-fpm.d/zz-docker.conf

COPY ./bin/oz-healthcheck /usr/local/bin/oz-healthcheck
HEALTHCHECK --interval=30s --timeout=10s CMD /usr/local/bin/oz-healthcheck

## General
COPY ./bin/oz-start-laravel /usr/local/bin/oz-start-laravel
RUN chmod u+x /usr/local/bin/oz-start-laravel

## PHP config & extensions
RUN apt-get install -y libtidy-dev zlib1g-dev libpng-dev libjpeg-dev libfreetype6-dev
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install pdo_mysql tidy zip gd exif

COPY ./config/php.ini /usr/local/etc/php/

## Composer
RUN apt-get install -y git unzip
COPY --from=composer:1 /usr/bin/composer /usr/bin/composer

## Cronjob (Laravel Schedule)
RUN apt-get install -y cron
RUN (crontab -u www-data -l; echo "* * * * * /usr/local/bin/php /var/www/artisan schedule:run >> /dev/null 2>&1") | crontab -u www-data -

##
# The following commands are ran at build time only, allowing the actual
# source code to be added to the image
##
ONBUILD COPY src/ /var/www/
ONBUILD RUN rm -rf tests

ONBUILD RUN mkdir -p bootstrap/cache
ONBUILD RUN mkdir -p storage/app/public
ONBUILD RUN mkdir -p storage/framework/cache
ONBUILD RUN mkdir -p storage/framework/sessions
ONBUILD RUN mkdir -p storage/framework/views
ONBUILD RUN mkdir -p storage/logs

ONBUILD RUN COMPOSER_ALLOW_SUPERUSER=1 composer install -n -o --prefer-dist --no-dev

## We don't need Git now that composer has installed everything
ONBUILD RUN apt-get purge -y git && apt-get autoremove -y

CMD /usr/local/bin/oz-start-laravel
