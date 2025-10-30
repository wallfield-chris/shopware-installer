FROM php:8.2-cli

# Systeem deps + PHP-extensies voor Shopware
RUN apt-get update && apt-get install -y --no-install-recommends \
      git unzip libicu-dev libzip-dev libonig-dev libpng-dev libjpeg-dev libxml2-dev \
  && docker-php-ext-configure intl \
  && docker-php-ext-install -j"$(nproc)" intl pdo_mysql opcache bcmath zip exif \
  && rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

WORKDIR /app
COPY . /app

# PHP dependencies
RUN composer install --no-dev --optimize-autoloader --prefer-dist --no-interaction

# Kinsta verwacht dat je op 8080 luistert
ENV PORT=8080

# Serve /public als webroot
CMD sh -lc 'php -S 0.0.0.0:${PORT} -t public public/index.php'
