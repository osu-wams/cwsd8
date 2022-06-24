#!/bin/sh
#
# Cloud Hook: update-db
#
# Run drush updatedb in the target environment. This script works as
# any Cloud hook.

site="$1"
target_env="$2"
echo"Using Drush Launcher Version"
echo $(drush10 --version)
#drush10 @$site.$target_env updatedb --yes --no-ansi
find sites -maxdepth 1 -type d -not -name sites -printf '%f\n' | while IFS=/ read -r DOMAIN; do printf "%s," ${DOMAIN}; drush -l $DOMAIN updatedb -y; drush -l $DOMAIN cr; done
