#!/bin/sh
#
# Cloud Hook: drush-cache-clear
#
# Run drush cache-clear all in the target environment. This script works as
# any Cloud hook.


# Map the script inputs to convenient names.
site=$1
target_env=$2
drush_alias=$site'.'$target_env
echo "Flushing caches"
echo $(drush10 --version)
# Execute a standard drush command.
drush10 @$drush_alias cr --no-ansi
