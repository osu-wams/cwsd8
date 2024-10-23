#!/bin/sh
#
# Cloud Hook: post-db-copy
#
# The post-db-copy hook is run whenever you use the Workflow page to copy a
# database from one environment to another. See ../README.md for
# details.
#
# Usage: post-db-copy site target-env db-name source-env

site="$1"
target_env="$2"
db_name="$3"
source_env="$4"
DRUPAL_ROOT="/var/www/html/docroot"
URI=$(grep -l osuglobal_oregonstate_edu ${DRUPAL_ROOT}/sites/**/settings.php | cut -d '/' -f2)
drush --no-ansi --root=${DRUPAL_ROOT} @"${site}"."${target_env}" -l "${URI}" cr
