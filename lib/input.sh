#!/bin/bash

set -eo pipefail

function read_yes_no() {
  local data
  local default
  local OPTIND

  while getopts 'ny' flag; do
    case "${flag}" in
      n) default="n" ;;
      y) default="y" ;;
    esac
  done

  shift $(($OPTIND - 1))
  
  while true; do
    echo -n "${1-"Yes or no?"} [y|n]: "
    read data

    if [[ ! -z $default ]]; then
      data=${data:-"${default}"}
    fi

    case $data in
      Y|y|yes ) return 0 ;;
      N|n|no ) return 1 ;;
    esac
  done
}
