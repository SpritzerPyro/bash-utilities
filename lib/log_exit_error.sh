#!/bin/bash

source $(dirname ${BASH_SOURCE[0]:-$0})/log.sh

set -o errexit
set -o pipefail

function read_and_log_stderr() {
  while read line;
    do log_error $line;
  done
}

function log_errexit_trap() {
  [[ $1 == "0" ]] && return 0

  IFS=' ' read -ra caller_array <<< "$(caller)"
  caller_path=$(readlink -f ${caller_array[1]})

  log_error "$caller_path exited with code $1"
}

exec 2> >(read_and_log_stderr)

trap 'log_errexit_trap $?' EXIT
