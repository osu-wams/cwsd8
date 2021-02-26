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
drush10 @$site.$target_env updatedb --yes --no-ansi
