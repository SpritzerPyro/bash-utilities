# shellcheck shell=bash

function _config::arg_state() {
  local -r option=$(set -o | grep "$1" || echo "")

  echo "${option}" | sed -r 's/.*\s+//'
}

function _config::init_dirs() {
  export USER="${USER:-"${LOGNAME}"}"

  declare -A -g DIRS
  local -r home_dir="${HOME:-"/home/${USER}"}"
  local -r media_dir="/media/${USER}"

  DIRS[script]=$(dirname "$(readlink -f "$0")")
  DIRS[working]=$(pwd)

  if [[ -d "${home_dir}" ]]; then
    DIRS[home]="${home_dir}"
  fi

  if [[ -d "${media_dir}" ]]; then
    # shellcheck disable=SC2034
    DIRS[media]="${media_dir}"
  fi
}

function _config::init_log() {
  local i
  declare -A -g BUTILS_COLORS
  declare -A -g BUTILS_LOG_LEVELS=(
    [debug]=DEBUG
    [emph]=INFO
    [error]=ERROR
    [info]=INFO
    [success]=INFO
    [warn]=WARN
  )

  for i in "${!BUTILS_LOG_LEVELS[@]}" default prefix; do
    local varname="BUTILS_COLOR_${i^^}"

    BUTILS_COLORS["${i}"]="${!varname:-"${BUTILS_COLOR_DEFAULT}"}"
  done
}

function _config::log_info() {
  local _level=info
  local i

  for i in "${!BUTILS_LOG_LEVELS[@]}"; do
    [[ "$2" != "${i}" ]] && continue

    _level="${i}"
  done

  local _color="${BUTILS_COLORS["${_level}"]}"
  local _key="${BUTILS_LOG_LEVELS["${_level}"]}"

  eval "$1=([color]=\"${_color}\" [level]=\"${_level}\" [key]=\"${_key}\")"
}

function _config::load_env {
  : "${BUTILS_COLOR_DEBUG:="\\033[0;36m"}"
  : "${BUTILS_COLOR_DEFAULT:="\\033[0m"}"
  : "${BUTILS_COLOR_EMPH:="\\033[0;34m"}"
  : "${BUTILS_COLOR_ERROR:="\\033[0;31m"}"
  : "${BUTILS_COLOR_INFO:="\\033[0m"}"
  : "${BUTILS_COLOR_PREFIX:="\\033[0;90m"}"
  : "${BUTILS_COLOR_SUCCESS:="\\033[0;32m"}"
  : "${BUTILS_COLOR_WARN:="\\033[0;33m"}"
  : "${BUTILS_LOG_MAX_SIZE:=20971520}"
  : "${BUTILS_LOG_MULTILINE_PREFIX="> "}"
  : "${BUTILS_LOG_TIME_FORMAT:="%Y-%m-%dT%H:%M:%S.%3N%:z"}"
}

function _config::init {
  _config::load_env
  _config::init_dirs
  _config::init_log
}
