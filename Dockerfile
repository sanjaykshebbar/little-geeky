# Author       : Sanjay KS
# Email        : sanjaykshebbar@gmail.com
# CreatedDate  : 2025-08-10
# Version      : 1.0.3
# Description  : PHP 8.1 Apache image for little-geeky; multi-arch friendly; enables rewrite and common PHP extensions.
#
# ---------------- CHANGE LOG ----------------
# Date         : 2025-08-10
# ChangesMade  : Converted header to hash-style comments (Dockerfile only supports #). Ensured multi-arch base and modules.

FROM php:8.1-apache

# Enable Apache modules (rewrite for .htaccess, headers commonly used)
RUN a2enmod rewrite headers

# Install PHP extensions needed by the app (adjust as needed)
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Copy application into Apache docroot
WORKDIR /var/www/html
COPY . /var/www/html/

# Allow .htaccess overrides if the app uses rewrite rules
RUN sed -i 's/AllowOverride None/AllowOverride All/i' /etc/apache2/apache2.conf

# Fix permissions for Apache user
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
