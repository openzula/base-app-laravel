FROM php:7.2-fpm
LABEL maintainer="alex@openzula.org"

EXPOSE 9000
WORKDIR /var/www

RUN apt-get update

COPY ./bin/oz-start-laravel /usr/local/bin/oz-start-laravel
RUN chmod u+x /usr/local/bin/oz-start-laravel

## PHP config & extensions
RUN apt-get install -y libtidy-dev zlib1g-dev libpng-dev libjpeg-dev libfreetype6-dev
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install pdo_mysql tidy zip gd exif

COPY ./config/php.ini /usr/local/etc/php/

## Composer
RUN apt-get install -y git
COPY --from=composer:1.6 /usr/bin/composer /usr/bin/composer

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

ONBUILD RUN chown -R www-data:www-data bootstrap/cache storage
ONBUILD RUN composer install -n -o --prefer-dist --no-dev

## We don't need Git now that composer has installed everything
ONBUILD RUN apt-get purge -y git && apt-get autoremove -y

CMD /usr/local/bin/oz-start-laravel
