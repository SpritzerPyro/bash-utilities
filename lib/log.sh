#!/bin/bash

source $(dirname ${BASH_SOURCE[0]:-$0})/echo.sh
source $(dirname ${BASH_SOURCE[0]:-$0})/log.env
source $(dirname ${BASH_SOURCE[0]:-$0})/sourceenv.sh

function handle_log_file() {
  if [[ -z $BASH_UTILS_LOG_PATH ]]; then
    return
  fi

  if [[ -f $BASH_UTILS_LOG_PATH ]]; then
    local size=$(stat -c %s $BASH_UTILS_LOG_PATH)

    if [[ $size -gt $BASH_UTILS_MAX_LOG_SIZE ]]; then
      local i=1
      while [[ -f $BASH_UTILS_LOG_PATH.$i ]]; do ((i=i+1)); done
      mv $BASH_UTILS_LOG_PATH $BASH_UTILS_LOG_PATH.$i
    fi
  fi

  if [[ ! -f $BASH_UTILS_LOG_PATH ]]; then
    mkdir -p $(dirname $BASH_UTILS_LOG_PATH)
    touch $BASH_UTILS_LOG_PATH
  fi
}

function log_emph() {
  [[ -z $BASH_UTILS_LOG_PATH ]] && return
  handle_log_file
  echo -e "$(echo_prefix "emph    :") $(echo_emph $@)" >> $BASH_UTILS_LOG_PATH
}

function log_error() {
  [[ -z $BASH_UTILS_LOG_PATH ]] && return
  handle_log_file
  echo -e "$(echo_prefix "error   :") $(echo_error $@)" >> $BASH_UTILS_LOG_PATH
}

function log_info() {
  [[ -z $BASH_UTILS_LOG_PATH ]] && return
  handle_log_file
  echo -e "$(echo_prefix "info    :") $(echo_info $@)" >> $BASH_UTILS_LOG_PATH
}

function log_success() {
  [[ -z $BASH_UTILS_LOG_PATH ]] && return
  handle_log_file
  echo -e "$(echo_prefix "success :") $(echo_success $@)" >> $BASH_UTILS_LOG_PATH
}

function log_warn() {
  [[ -z $BASH_UTILS_LOG_PATH ]] && return
  handle_log_file
  echo -e "$(echo_prefix "warning :") $(echo_warn $@)" >> $BASH_UTILS_LOG_PATH
}

function log() {
  local echoonly=false
  local level=info
  local OPTIND
  local silent=false

  while getopts 'el:s' flag; do
    case $flag in
      e) echoonly=true ;;
      l) level=$OPTARG ;;
      s) silent=true ;;
    esac
  done

  shift $(($OPTIND - 1))

  if [[ $# -gt 0 ]]; then
    case $level in
      emph)
        [[ $silent != "true" ]] && echo_emph "$@"
        [[ $echoonly != "true" ]] && log_emph "$@"
        ;;
      error)
        [[ $silent != "true" ]] && echo_error "$@"
        [[ $echoonly != "true" ]] && log_error "$@"
        ;;
      success)
        [[ $silent != "true" ]] && echo_success "$@"
        [[ $echoonly != "true" ]] && log_success "$@"
        ;;
      warn | warning)
        [[ $silent != "true" ]] && echo_warn "$@"
        [[ $echoonly != "true" ]] && log_warn "$@"
        ;;
      *)
        [[ $silent != "true" ]] && echo_info "$@"
        [[ $echoonly != "true" ]] && log_info "$@"
        ;;
    esac

    return
  fi

  while read data; do
    case $level in
      emph)
        [[ $silent != "true" ]] && echo_emph "$data"
        [[ $echoonly != "true" ]] && log_emph "$data"
        ;;
      error)
        [[ $silent != "true" ]] && echo_error "$data"
        [[ $echoonly != "true" ]] && log_error "$data"
        ;;
      success)
        [[ $silent != "true" ]] && echo_success "$data"
        [[ $echoonly != "true" ]] && log_success "$data"
        ;;
      warn | warning)
        [[ $silent != "true" ]] && echo_warn "$data"
        [[ $echoonly != "true" ]] && log_warn "$data"
        ;;
      *)
        [[ $silent != "true" ]] && echo_info "$data"
        [[ $echoonly != "true" ]] && log_info "$data"
        ;;
    esac
  done
}
