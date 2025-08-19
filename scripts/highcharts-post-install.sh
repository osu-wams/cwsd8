#!/usr/bin/env bash
set -eu
declare -a highcharts_libraries=(
  "docroot/libraries/highcharts/highcharts-3d.js"
  "docroot/libraries/highcharts/highcharts-more.js"
  "docroot/libraries/highcharts/modules/accessibility.js"
  "docroot/libraries/highcharts/modules/annotations.js"
  "docroot/libraries/highcharts/modules/boost.js"
  "docroot/libraries/highcharts/modules/data.js"
  "docroot/libraries/highcharts/modules/drilldown.js"
  "docroot/libraries/highcharts/modules/exporting.js"
  "docroot/libraries/highcharts/modules/export-data.js"
  "docroot/libraries/highcharts/modules/map.js"
  "docroot/libraries/highcharts/modules/heatmap.js"
  "docroot/libraries/highcharts/modules/no-data-to-display.js"
  "docroot/libraries/highcharts/modules/pattern-fill.js"
  "docroot/libraries/highcharts/themes/high-contrast-light.js"
)

for LIBRARY in "${highcharts_libraries[@]}"
do
  BASENAME=$(basename "${LIBRARY}" .js);
  if [[ $(echo "${BASENAME}" | cut -d '-' -f1) == 'highcharts' ]]; then
    LIBRARY_NAME=$(echo "${BASENAME}" | tr '-' '_');
  else
    LIBRARY_NAME="highcharts_${BASENAME}";
  fi
  mkdir -p docroot/libraries/"${LIBRARY_NAME}";
  cp "${LIBRARY}" docroot/libraries/"${LIBRARY_NAME}"/;
done
