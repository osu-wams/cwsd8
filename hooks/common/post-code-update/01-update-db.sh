#!/bin/sh
#
# Cloud Hook: update-db
#
# Run drush updatedb in the target environment. This script works as
# any Cloud hook.

site="$1"
target_env="$2"
find sites -maxdepth 1 -type d -not -name sites -printf '%f\n' | while IFS=/ read -r DOMAIN; do printf "%s," "${DOMAIN}"; \
  drush @"${site}"."${target_env}" -l "${DOMAIN}" updatedb -y; \
  drush @"${site}"."${target_env}" -l "${DOMAIN}" cr; \
done
