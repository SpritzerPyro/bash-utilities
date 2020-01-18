#!/bin/bash

function dotenv_is_valid() {
  local data=$(grep -Ev "^(\S+=|#|$)" $1 || true)

  [[ -z $data ]]
}

function export_dotenv() {
  if [[ ! -f $1 ]]; then
    echo "export_dotenv: File '$1' does not exist" >&2
    return 1
  fi

  if ! dotenv_is_valid $1; then
    echo "export_dotenv: File '$1' is not a valid dotenv file" >&2
    return 1
  fi

  set -a
  source $1
  set +a
}

function export_dotenvs() {
  for i in $@; do
    [[ ! -f $i ]] && continue
    export_dotenv $i
  done
}

function export_to_env() {
  grep -E "^export\s\S+=" $1 | sed 's/export\s//'
}

function source_dotenv() {
  if [[ ! -f $1 ]]; then
    echo "source_dotenv: File '$1' does not exist" >&2
    return 1
  fi

  if ! dotenv_is_valid $1; then
    echo "source_dotenv: File '$1' is not a valid dotenv file" >&2
    return 1
  fi

  source $1
}

function source_dotenvs() {
  for i in $@; do
    [[ ! -f $i ]] && continue
    source_dotenv $i
  done
}
