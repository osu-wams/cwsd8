#!/usr/bin/env bash

# Run drush schedular cron for the Environments default site and log the output.
# $1 (Optional) URI provided to drush, defaults to site
#    default FQDN.

if [ -n "${1}" ]; then
  uri="${1}"
else
  uri="${AH_SITE_NAME}.${AH_REALM}.acquia-sites.com"
fi

drush \
  --root="/var/www/html/docroot/" \
  --uri="${uri}" \
  scheduler:cron
DRUSH_EXIT_CODE=$?
exit $DRUSH_EXIT_CODE
