FROM php:8.2-fpm-alpine

# Install system dependencies and PHP extensions needed by Symfony
RUN apk add --no-cache \
        bash \
        git \
        unzip \
        icu-dev \
        libzip-dev \
        oniguruma-dev \
        libpng-dev \
        libjpeg-turbo-dev \
        freetype-dev \
        curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        intl \
        zip \
        pdo_mysql \
        opcache \
        gd \
    && rm -rf /var/cache/apk/*

# Install Composer (copy from official image to keep it small)
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# PHP dev config
COPY php.ini /usr/local/etc/php/conf.d/php-dev.ini

# Create a non-root user (optional, useful on some systems)
RUN addgroup -g 1000 symfony && adduser -D -G symfony -u 1000 symfony \
    && chown -R symfony:symfony /var/www/html

USER symfony
