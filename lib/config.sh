function config::init() {
  export USER="${USER:-"${LOGNAME}"}"

  declare -A -g DIRS
  local -r home_dir="${HOME:-"/home/${USER}"}"
  local -r lib_dir=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
  local -r media_dir="/media/${USER}"

  DIRS[butils_lib]="${lib_dir}"
  DIRS[butils]=$(readlink -f "${lib_dir}/..")
  DIRS[script]=$(dirname $(readlink -f "$0"))
  DIRS[working]=$(pwd)

  if [[ -d "${home_dir}" ]]; then
    DIRS[home]="${home_dir}"
  fi

  if [[ -d "${media_dir}" ]]; then
    DIRS[media]="${media_dir}"
  fi
}

function config::source() {
  local -r butils_dir=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")/..")

  source "${butils_dir}/lib/dotenv.sh"

  for var in $(cat "${butils_dir}/config/variables"); do
    [[ -n "${!var+set}" ]] && continue

    dotenv::source -s -v "${var}" \
      "${butils_dir}/config/default.env" \
      "${butils_dir}/../.bashutils.env" \
      "${butils_dir}/../.env" \
      "${butils_dir}/.bashutils.env" \
      "${butils_dir}/.env"
  done
}
