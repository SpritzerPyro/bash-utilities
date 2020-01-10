#!/bin/bash

function export_dotenv() {
  [[ ! -f $1 ]] && return 1

  set -a
  source $1
  set +a
}

function export_dotenvs() {
  for i in $1/*.env; do
    [[ ! -f $i ]] && continue
    export_dotenv $i
  done
}

function export_to_env() {
  grep -E "^export\s\S+=" $1 | sed 's/export\s//'
}
