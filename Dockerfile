FROM php:8.3-apache

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libicu-dev \
    libonig-dev \
    libxml2-dev \
    libsqlite3-dev \
    default-mysql-client \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        gd \
        intl \
        mbstring \
        opcache \
        pdo \
        pdo_mysql \
        zip \
    && a2enmod rewrite headers expires \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY composer.json composer.lock ./

RUN composer install --no-dev --optimize-autoloader --no-interaction

COPY . .

RUN chown -R www-data:www-data /var/www/html

COPY apache/vhost.conf /etc/apache2/sites-available/000-default.conf

EXPOSE 80

CMD ["apache2-foreground"]