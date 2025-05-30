FROM ghcr.io/osu-wams/php:8.3-apache AS production
COPY docker-wams-entry /usr/local/bin
ENV PATH="$PATH:/var/www/html/vendor/bin"
WORKDIR /var/www/html
USER www-data
COPY --chown=www-data:www-data . /var/www/html
RUN --mount=type=secret,id=composer_auth,env=COMPOSER_AUTH \
    composer install -o --no-dev
RUN mkdir -p /var/www/html/docroot/sites/default/files; \
  chown -R www-data:www-data /var/www/html/docroot/sites/default/files; \
  mkdir -p /var/www/files-private; \
  chown -R www-data:www-data /var/www/files-private;
VOLUME /var/www/html/docroot/sites/default/files
ENTRYPOINT [ "docker-wams-entry" ]
CMD [ "apache2-foreground" ]

FROM ghcr.io/osu-wams/php:8.3-apache-dev AS development
USER root
RUN echo 'sendmail_path = "/usr/local/bin/mhsendmail --smtp-addr=mailhog:1025"' > /usr/local/etc/php/conf.d/sendmail.ini;
USER www-data
COPY docker-wams-entry /usr/local/bin
ENV PATH="$PATH:/var/www/html/vendor/bin"
WORKDIR /var/www/html
COPY --from=production /var/www/html /var/www/html
RUN --mount=type=secret,id=composer_auth,env=COMPOSER_AUTH \
    composer install -o
ENTRYPOINT [ "docker-wams-entry" ]
CMD [ "apache2-foreground" ]
