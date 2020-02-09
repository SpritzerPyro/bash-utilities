#!/bin/bash

set -eo pipefail

function query() {
  local allow_empty_input
  local local_read_answer
  local local_read_default
  local OPTIND
  local path

  while getopts 'd:ep' flag; do
    case "${flag}" in
      d) local_read_default=$OPTARG ;;
      e) allow_empty_input=true ;;
      p) path=true ;;
    esac
  done

  shift $(($OPTIND - 1))

  while true; do
    if [[ -z $local_read_default ]]; then
      echo -n "${1-"Input"}: "
    else
      echo -n "${1-"Input"} ($local_read_default): "
    fi

    read local_read_answer

    if [[ ! -z $local_read_default ]]; then
      local_read_answer=${local_read_answer:-"${local_read_default}"}
    fi

    if [[ -z $local_read_answer ]] && [[ $allow_empty_input != "true" ]]; then
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
