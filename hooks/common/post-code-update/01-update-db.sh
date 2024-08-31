#!/bin/sh
#
# Cloud Hook: update-db
#
# Run drush updatedb in the target environment. This script works as
# any Cloud hook.

site="$1"
target_env="$2"
app_root="/var/www/html/${site}.${target_env}/docroot"
sites_folder="${app_root}/sites"

# Function to run drush updatedb and cr
run_drush() {
  local DOMAIN="$1"
  drush --root="${app_root}" @"${site}"."${target_env}" -l "${DOMAIN}" updatedb -y
  drush --root="${app_root}" @"${site}"."${target_env}" -l "${DOMAIN}" cr
}

export -f run_drush

# Check if GNU parallel is installed
if command -v parallel > /dev/null 2>&1; then
  echo "GNU parallel found. Running with parallel."

  find ${sites_folder} -maxdepth 1 -type d -not -name sites -printf '%f\n' | \
  parallel -j 6 run_drush {}
else
  echo "GNU parallel not found. Running sequentially."

  find ${sites_folder} -maxdepth 1 -type d -not -name sites -printf '%f\n' | \
  while IFS=/ read -r DOMAIN; do
    run_drush "${DOMAIN}"
  done
fi

