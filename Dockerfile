/*
 * Author       : Sanjay KS
 * Email        : sanjaykshebbar@gmail.com
 * CreatedDate  : 2025-08-10
 * Version      : 1.0.2
 * Description  : PHP 8.1 Apache image for little-geeky; multi-arch friendly base; enables rewrite and common PHP extensions.
 * 
 * ---------------- CHANGE LOG ----------------
 * Date         : 2025-08-10
 * ChangesMade  : Ensured multi-arch base; enabled Apache rewrite; installed PHP extensions; copied app; set permissions.
 */

FROM php:8.1-apache

# Enable Apache modules commonly needed for PHP apps
RUN a2enmod rewrite headers

# Install PHP extensions required by many PHP apps (adjust if needed)
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Copy application into the default Apache docroot
WORKDIR /var/www/html
COPY . /var/www/html/

# If using .htaccess with rewrites, allow overrides
RUN sed -i 's/AllowOverride None/AllowOverride All/i' /etc/apache2/apache2.conf

# Set appropriate permissions for Apache user
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
