#!/bin/bash

source $(dirname ${BASH_SOURCE[0]:-$0})/checks.sh
source $(dirname ${BASH_SOURCE[0]:-$0})/log.sh

set -o errexit
set -o pipefail

function read_and_log_stderr() {
  while read line; do
    echo $line | log -l error;
  done
}

function log_errexit_trap() {
  [[ $1 == "0" ]] && return 0

  IFS=' ' read -ra caller_array <<< "$(caller)"
  caller_path=$(readlink -f ${caller_array[1]})

  echo "$caller_path exited with code $1" | log -l error
}

is_false $BASH_UTILS_LOG_STDERR || exec 2> >(read_and_log_stderr)

trap 'log_errexit_trap $?' EXIT
