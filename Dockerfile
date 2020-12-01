FROM docker.io/library/php:7.4-apache
RUN set -eux; \
  apt-get update; \
  apt-get upgrade -y; \
  apt-get install -y --no-install-recommends \
    git \
    libfreetype6-dev \
    libjpeg-dev \
    libmemcached-dev \
    libpng-dev \
    libpq-dev \
    libzip-dev \
    mariadb-client \
    vim \
  ; \
  yes ' ' | pecl install memcached; \
  docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg=/usr \
  ; \
  docker-php-ext-enable \
    memcached \
  ; \
  docker-php-ext-install -j "$(nproc)" \
    gd \
    opcache \
    pdo_mysql \
    pdo_pgsql \
    zip \
  ;
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=60'; \
    echo 'opcache.fast_shutdown=1'; \
} > /usr/local/etc/php/conf.d/opcache-recommended.ini
RUN sed -i "s/\/var\/www\/html/\/var\/www\/html\/docroot/" /etc/apache2/sites-available/000-default.conf; \
  chown www-data:www-data /var/www;
WORKDIR /tmp
RUN set -eux; \
  curl https://raw.githubusercontent.com/composer/getcomposer.org/76a7060ccb93902cd7576b67264ad91c8a2700e2/web/installer -o composer-setup.php; \
  php composer-setup.php --install-dir=/usr/local/bin --filename=composer; \
  rm composer-setup.php;
WORKDIR /var/www/html
COPY --chown=www-data:www-data . /var/www/html
USER www-data
RUN composer install -o
USER root
COPY docker-wams-entry /usr/local/bin
ENV PATH "$PATH:/var/www/html/vendor/bin"
ENTRYPOINT [ "docker-wams-entry" ]
CMD [ "apache2-foreground" ]
