FROM php:8.1-fpm
RUN apt-get update

RUN mkdir -p /var/www/app

RUN apt-get update && apt-get install -y libpq-dev && docker-php-ext-install pdo pdo_pgsql


RUN chown -R www-data:www-data /var/www

USER www-data
