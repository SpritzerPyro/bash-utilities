#!/bin/bash

bash_utils_custom_env_paths=(
  "../.bashutils.env"
  "../.env"
  "../../.bashutils.env"
)

for path in ${bash_utils_custom_env_paths[@]}; do
  [[ ! -f $(dirname ${BASH_SOURCE[0]:-$0})/$path ]] && continue

  source $(dirname ${BASH_SOURCE[0]:-$0})/$path
  break;
done
