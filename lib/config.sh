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
    [debug]=debug
    [emph]=info
    [error]=error
    [info]=info
    [success]=info
    [warn]=warn
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
