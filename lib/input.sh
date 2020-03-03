#!/bin/bash

set -eo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/checks.sh"

function query() {
  local email
  local local_read_answer
  local local_read_default
  local OPTARG OPTIND
  local optional
  local path

  while getopts 'd:eop' flag; do
    case "${flag}" in
      d) local_read_default="${OPTARG}" ;;
      e) email="true" ;;
      o) optional="true" ;;
      p) path="true" ;;
    esac
  done

  shift $(($OPTIND - 1))

  while true; do
    if [[ ! -z $local_read_default ]]; then
      echo -n "${1-"Input"} ($local_read_default): "
    elif [[ "${optional}" == "true" ]]; then
      echo -n "${1-"Input"} (optional): "
    else
      echo -n "${1-"Input"}: "
    fi

    read local_read_answer

    if [[ ! -z $local_read_default ]]; then
      local_read_answer=${local_read_answer:-"${local_read_default}"}
    fi

    if [[ -z $local_read_answer ]] && [[ $optional != "true" ]]; then
      echo "Required"
      continue
    fi

    if
      [[ "${email}" == "true" ]] && \
      ! is_valid_email "${local_read_answer}" && \
      ([[ ! -z "${local_read_answer}" ]] || [[ "${optional}" != "true" ]])
    then
      echo "Invalid email"
      continue
    fi

    if [[ $path == "true" ]]; then
      local_read_answer=$(echo $local_read_answer | sed "s#^~#$HOME#")
    fi

    eval "$2='$local_read_answer'"
    return
  done
}

function query_yes_no() {
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
    if [[ -z $local_read_default ]]; then
      echo -n "${1-"Yes or no?"} [y|n]: "
    else
      echo -n "${1-"Yes or no?"} [y|n] ($local_read_default): "
    fi

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
