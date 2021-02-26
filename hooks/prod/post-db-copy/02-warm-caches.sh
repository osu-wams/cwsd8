#!/bin/sh

site="$1"
target_env="$2"
echo"Using Drush Version"
echo $(drush9 --version --no-ansi)
drush9 @$site.$target_env warmer:enqueue jsonapi --no-ansi
drush9 @$site.$target_env queue:run warmer --no-ansi
