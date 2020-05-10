function config::get_log_level() {
  local level=info
  local color="${BASH_UTILS_LOG_COLORS["${level}"]}"
  local key="${BASH_UTILS_LOG_LEVELS["${level}"]}"

  for i in ${!BASH_UTILS_LOG_LEVELS[@]}; do
    [[ "$2" != "${i}" ]] && continue

    level="${i}"
    key="${BASH_UTILS_LOG_LEVELS["${i}"]}"
  done

  for i in ${!BASH_UTILS_LOG_COLORS[@]}; do
    [[ "$2" != "${i}" ]] && continue

    color="${BASH_UTILS_LOG_COLORS["${i}"]}"
  done

  eval "$1=([color]=\"${color}\" [level]=\"${level}\" [key]=\"${key}\")"
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
  declare -A -g BASH_UTILS_LOG_COLORS
  declare -A -g BASH_UTILS_LOG_LEVELS=(
    [debug]=DEBUG
    [emph]=INFO
    [error]=ERROR
    [info]=INFO
    [success]=INFO
    [warn]=WARN
  )

  for i in ${!BASH_UTILS_LOG_LEVELS[@]}; do
    local varname="BASH_UTILS_COLOR_${i^^}"
    BASH_UTILS_LOG_COLORS["${i}"]="${!varname:-"${BASH_UTILS_COLOR_DEFAULT}"}"
  done
}

function config::source {
  local -r cfg_dir=$(readlink -f $(dirname "${BASH_SOURCE[0]}")/../config)
  local var

  for var in $(cat "${cfg_dir}/variables"); do
    [[ -n "${!var+set}" ]] && continue

    source <(grep -s "^${var}=" "${cfg_dir}/default.env")
  done
}

function config::init {
  config::source
  config::init_dirs
  config::init_log
}
