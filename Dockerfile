FROM docker.io/osuwams/php:8.1-apache AS production
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

FROM docker.io/osuwams/php:8.1-apache-dev AS development
COPY docker-wams-entry /usr/local/bin
ENV PATH "$PATH:/var/www/html/vendor/bin"
WORKDIR /var/www/html
COPY --from=production /var/www/html /var/www/html
RUN composer install -o
ENTRYPOINT [ "docker-wams-entry" ]
CMD [ "apache2-foreground" ]
