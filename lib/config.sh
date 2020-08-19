function config::arg_state() {
  local -r option=$(set -o | grep "$1" || echo "")

  echo "${option}" | sed -r 's/.*\s+//'
}

function config::init_dirs() {
  export USER="${USER:-"${LOGNAME}"}"

  declare -A -g DIRS
  local -r home_dir="${HOME:-"/home/${USER}"}"
  local -r media_dir="/media/${USER}"

  DIRS[script]=$(dirname $(readlink -f "$0"))
  DIRS[working]=$(pwd)

  if [[ -d "${home_dir}" ]]; then
    DIRS[home]="${home_dir}"
  fi

  if [[ -d "${media_dir}" ]]; then
    DIRS[media]="${media_dir}"
  fi
}

function config::init_log() {
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

  for i in ${!BUTILS_LOG_LEVELS[@]} default prefix; do
    local varname="BUTILS_COLOR_${i^^}"

    BUTILS_COLORS["${i}"]="${!varname:-"${BUTILS_COLOR_DEFAULT}"}"
  done
}

function config::log_info() {
  local _level=info
  local i

  for i in ${!BUTILS_LOG_LEVELS[@]}; do
    [[ "$2" != "${i}" ]] && continue

    _level="${i}"
  done

  local _color="${BUTILS_COLORS["${_level}"]}"
  local _key="${BUTILS_LOG_LEVELS["${_level}"]}"

  eval "$1=([color]=\"${_color}\" [level]=\"${_level}\" [key]=\"${_key}\")"
}

function config::source {
  local -r cfg_dir="$(dirname $(readlink -f "${BASH_SOURCE[0]}"))/../config"
  local variable

  for variable in $(cat "${cfg_dir}/variables"); do
    [[ -n "${!variable+set}" ]] && continue

    source <(grep -s "^${variable}=" "${cfg_dir}/default.env")
  done
}

function config::init {
  config::source
  config::init_dirs
  config::init_log
}
