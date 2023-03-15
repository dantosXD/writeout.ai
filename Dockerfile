# Use the official PHP image with Apache
FROM php:8.0-apache

# Install Git, unzip and dependencies for Laravel
RUN apt-get update && \
    apt-get install -y git unzip libpq-dev libpng-dev libonig-dev libxml2-dev libzip-dev && \
    docker-php-ext-install pdo_pgsql gd mbstring xml tokenizer zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Clone the repository
RUN git clone https://github.com/beyondcode/writeout.ai.git /var/www/html

# Run Composer install
RUN composer install --working-dir=/var/www/html

# Copy .env.example to .env
RUN cp /var/www/html/.env.example /var/www/html/.env

# Run Laravel commands
RUN php /var/www/html/artisan key:generate && \
    php /var/www/html/artisan migrate

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Update Apache configuration to point to /public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf

# Expose the default port for Laravel
EXPOSE 8000

# Run Laravel with the built-in server
CMD ["php", "/var/www/html/artisan", "serve", "--host=0.0.0.0", "--port=8000"]
