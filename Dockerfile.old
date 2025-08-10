# Use official PHP Apache image (example for index.php app)
FROM php:8.1-apache

# Enable Apache rewrite module
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli \
    && a2enmod rewrite

# Copy project files to web root
COPY . /var/www/html/

# Expose HTTP port
EXPOSE 80
