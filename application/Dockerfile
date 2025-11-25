FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    curl \
    libonig-dev \
    libzip-dev \
    libpq-dev \
    nodejs \
    npm \
    cron \
    && docker-php-ext-install pdo_mysql zip mbstring

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

RUN mkdir -p /root/.ssh && ssh-keyscan github.com >> /root/.ssh/known_hosts
COPY ssh/id_rsa /root/.ssh/
COPY ssh/id_rsa.pub /root/.ssh/

# Clone main Application
RUN cd ~/.ssh && eval "$(ssh-agent -s)" \ ssh-add id_rsa
ARG APPLICATION_REPO
ARG BACKEND_REPO
RUN git clone ${APPLICATION_REPO}

# Set permissions
WORKDIR /var/www/html
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Copy start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose Laravel dev server port
EXPOSE 8000

# Default command
CMD ["/start.sh"]