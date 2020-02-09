#!/bin/bash

set -eo pipefail

function read_yes_no() {
  local local_read_answer
  local local_read_default
  local OPTIND

  while getopts 'ny' flag; do
    case "${flag}" in
      n) local_read_default="n" ;;
      y) local_read_default="y" ;;
    esac
  done

  shift $(($OPTIND - 1))
  
  while true; do
    echo -n "${1-"Yes or no?"} [y|n]: "
    read local_read_answer

    if [[ ! -z $local_read_default ]]; then
      local_read_answer=${local_read_answer:-"${local_read_default}"}
    fi

    case $local_read_answer in
      Y|y|yes )
        if [[ ! -z $2 ]]; then
          eval "$2='yes'"
        fi

        return 0
        ;;
      N|n|no )
        if [[ -z $2 ]]; then
          return 1
        fi

        eval "$2='no'"
        return 0
        ;;
    esac
  done
}
