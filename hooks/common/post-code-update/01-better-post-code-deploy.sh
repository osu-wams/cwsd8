#!/bin/bash
#
# Cloud Hook: update-db
#
# Run drush updatedb in the target environment. This script works as
# any Cloud hook.

site="$1"
target_env="$2"
app_root="/var/www/html/docroot"
sites_folder="${app_root}/sites"
NUM_JOBS=$(nproc --all)  # Number of child processes to spawn

# Function to process a chunk of domains
process_chunk() {
  local start=$1
  local end=$2

  for (( i=start; i<end && i<TOTAL_DOMAINS; i++ )); do
    run_drush "${DOMAIN_ARRAY[$i]}"
    local DOMAIN="${DOMAIN_ARRAY[$i]}"
    echo "Updating ${DOMAIN}"
    drush --root="${app_root}" @"${site}"."${target_env}" -l "${DOMAIN}" updatedb -y
    drush --root="${app_root}" @"${site}"."${target_env}" -l "${DOMAIN}" cr
    echo "Finished Updating ${DOMAIN}"
  done
}

# Get all the sites and create a Bash array.
mapfile -t DOMAIN_ARRAY < <(find "${sites_folder}" -maxdepth 1 -type d -not -name sites -not -name default -printf '%f\n' | sort)
TOTAL_DOMAINS=${#DOMAIN_ARRAY[@]}
CHUNK_SIZE=$(( (TOTAL_DOMAINS + NUM_JOBS - 1) / NUM_JOBS ))  # Calculate chunk size

# Loop to spawn child processes
for (( job=0; job<NUM_JOBS; job++ )); do
  start=$(( job * CHUNK_SIZE ))
  end=$(( start + CHUNK_SIZE ))
  # Spawn child process for each chunk
  process_chunk $start $end &
done

# Wait for all child processes to finish
wait

echo "All drush operations completed."

