FROM docker.io/library/php:7.4-apache AS production
USER root
RUN set -eux; \
  if command -v a2enmod; then \
    a2enmod rewrite; \
  fi; \
  savedAptMark="$(apt-mark showmanual)"; \
  apt-get update; \
  apt-get upgrade -y; \
  # Installing Just Build dependencies
  apt-get install -y --no-install-recommends \
    libfreetype6-dev \
    libjpeg-dev \
    libmemcached-dev \
    libpng-dev \
    libpq-dev \
    libzip-dev \
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
  ; \
  apt-mark auto '.*' > /dev/null; \
  apt-mark manual $savedAptMark; \
  # Installing packages we want to keep
  apt-get install -y --no-install-recommends \
    git \
    unzip \
    mariadb-client \
  ; \
  ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
  | awk '/=>/ { print $3 }' \
  | sort -u \
  | xargs -r dpkg-query -S \
  | cut -d: -f1 \
  | sort -u \
  | xargs -rt apt-mark manual; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
  rm -rf /var/lib/apt/lists/*
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
COPY docker-wams-entry /usr/local/bin
ENV PATH "$PATH:/var/www/html/vendor/bin"
WORKDIR /var/www/html
USER www-data
COPY --chown=www-data:www-data . /var/www/html
RUN composer install -o --no-dev
RUN mkdir -p /var/www/html/docroot/sites/default/files; \
  chown -R www-data:www-data /var/www/html/docroot/sites/default/files;
VOLUME /var/www/html/docroot/sites/default/files
ENTRYPOINT [ "docker-wams-entry" ]
CMD [ "apache2-foreground" ]

FROM production AS development
USER root
RUN set -eux; \
  apt-get update; \
  apt-get upgrade -y; \
  apt-get install -y \
    vim \
    nano \
    wget \
  ; \
  yes ' ' | pecl install xdebug; \
  docker-php-ext-enable xdebug; \
  apt-get clean; \
  git clone https://github.com/gruvbox-community/gruvbox.git /usr/share/vim/vim81/pack/default/start/gruvbox ; \
  { \
    echo 'syntax on'; \
    echo 'set background=dark'; \
    echo 'set colorcolumn=80'; \
    echo 'set expandtab'; \
    echo 'set incsearch'; \
    echo 'set noerrorbells'; \
    echo 'set number'; \
    echo 'set relativenumber'; \
    echo 'set shiftwidth=4'; \
    echo 'set showmatch'; \
    echo 'set smartcase'; \
    echo 'set smartindent'; \
    echo 'set t_Co=256'; \
    echo 'set tabstop=4 softtabstop=4'; \
    echo 'set termguicolors'; \
    echo 'set wildmenu'; \
    echo 'set wildmode=longest,full'; \
    echo 'highlight ColorColumn ctermbg=0 guibg=lightgrey'; \
    echo 'colorscheme gruvbox'; \
    echo 'let g:skip_defaults_vim = 1'; \
    } > /etc/vim/vimrc.local;
USER www-data
WORKDIR /var/www/html
RUN composer install -o
