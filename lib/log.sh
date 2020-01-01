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
  echo_emph $@
  [[ -z $BASH_UTILS_LOG_PATH ]] && return
  handle_log_file
  echo -e "$(echo_prefix "emph    :") $(echo_emph $@)" >> $BASH_UTILS_LOG_PATH
}

function log_error() {
  echo_error $@
  [[ -z $BASH_UTILS_LOG_PATH ]] && return
  handle_log_file
  echo -e "$(echo_prefix "error   :") $(echo_error $@)" >> $BASH_UTILS_LOG_PATH
}

function log_info() {
  echo -e $@
  [[ -z $BASH_UTILS_LOG_PATH ]] && return
  handle_log_file
  echo -e "$(echo_prefix "info    :") $(echo_info $@)" >> $BASH_UTILS_LOG_PATH
}

function log_success() {
  echo_success $@
  [[ -z $BASH_UTILS_LOG_PATH ]] && return
  handle_log_file
  echo -e "$(echo_prefix "success :") $(echo_success $@)" >> $BASH_UTILS_LOG_PATH
}

function log_warn() {
  echo_warn $@
  [[ -z $BASH_UTILS_LOG_PATH ]] && return
  handle_log_file
  echo -e "$(echo_prefix "warning :") $(echo_warn $@)" >> $BASH_UTILS_LOG_PATH
}
