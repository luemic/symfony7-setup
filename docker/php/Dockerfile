# PHP 8.2 FPM with required extensions for Symfony and Doctrine (MariaDB)
FROM php:8.2-fpm-alpine

# Install system dependencies and PHP extensions
RUN set -eux; \
    apk add --no-cache \
        bash \
        git \
        icu-dev \
        oniguruma-dev \
        libzip-dev \
        zlib-dev \
        libpng-dev \
        freetype-dev \
        libjpeg-turbo-dev \
        mariadb-client \
    ; \
    docker-php-ext-configure gd --with-freetype --with-jpeg; \
    docker-php-ext-install -j"$(nproc)" \
        intl \
        pdo \
        pdo_mysql \
        zip \
        gd \
        opcache \
    ; \
    apk add --no-cache --virtual .build-deps $PHPIZE_DEPS linux-headers; \
    pecl install xdebug-3.3.2; \
    docker-php-ext-enable xdebug; \
    apk del .build-deps; \
    rm -rf /tmp/* /var/cache/apk/* /usr/local/lib/php/doc/* /usr/local/lib/php/test/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# PHP configuration
COPY php.ini /usr/local/etc/php/php.ini

WORKDIR /var/www/html/project
