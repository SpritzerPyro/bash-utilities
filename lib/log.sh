# shellcheck shell=bash

function log() {
  local flag OPTARG OPTIND
  local level="info"
  local _multiline=0

  while getopts 'l:m' flag; do
    case "${flag}" in
      l) level="${OPTARG}" ;;
      m) _multiline=1 ;;
      *) { echo "Invalid option provided" >&2; exit 1; } ;;
    esac
  done

  shift $(( OPTIND - 1 ))

  if (( _multiline )); then
    log::multiline -l "${level}" "$@"
    return
  fi

  if (( $# > 0 )); then
    chalk -l "${level}" "$@"
    log::write -l "${level}" "$@"

    return
  fi

  while read -r data; do
    chalk -l "${level}" "${data}"
    log::write -l "${level}" "${data}"
  done
}

function log::add() {
  local i

  for i in "$@"; do
    log::is_set "${i}" && continue

    _butils_log_paths+=("$(readlink -m "${i}")")
  done

  exec 2> >(while read -r line; do echo "${line}" | log -l error; done)

  trap 'log::exit_trap $?' EXIT
}

function log::exit_trap() {
  [[ "$1" == "0" ]] && return 0

  IFS=' ' read -ra caller_array <<< "$(caller)"
  caller_path=$(readlink -f "${caller_array[1]}")

  echo "${caller_path} exited with code $1" | log -l error
}

function log::is_set() {
  local data i path
  data=$(readlink -m "$1")

  for i in ${_butils_log_paths[@]+"${_butils_log_paths[@]}"}; do
    path=$(readlink -m "${i}")

    [[ "${data}" == "${path}" ]] && return 0
  done

  return 1
}

function log::multiline() {
  local _level=info
  local -A _loginfo
  local flag OPTARG OPTIND

  while getopts 'l:' flag; do
    case "${flag}" in
      l) _level="${OPTARG}" ;;
      *) { echo "Invalid option provided" >&2; exit 1; } ;;
    esac
  done

  shift $(( OPTIND - 1 ))

  _config::log_info _loginfo "${_level}"

  log -l "${_level}" "${*:-}"

  log::_tee -c "${_loginfo[color]}"

  echo "[Finished $(date +"${BUTILS_LOG_TIME_FORMAT}")]" \
    | log::_tee -c "${_loginfo[color]}"
}

# Allow use of the deprecated log::native function
function log::native() {
  log::multiline "$@"
}

function log::set() {
  declare -g _butils_log_paths=()

  log::add "$@"
}

function log::write() {
  local path

  for path in ${_butils_log_paths[@]+"${_butils_log_paths[@]}"}; do
    log::write_file -f "${path}" "$@"
  done
}

function log::write_file() {
  local flag OPTARG OPTIND
  local -A info
  local file size
  local level="info"
  local prefix=""

  while getopts 'f:l:' flag; do
    case "${flag}" in
      f) file="${OPTARG}" ;;
      l)
        [[ "${OPTARG}" == "off" ]] && return 0

        level="${OPTARG}"
        ;;
      *) { echo "Invalid option provided" >&2; exit 1; } ;;
    esac
  done

  if [[ ! "${file}" ]]; then
    echo "log::write_file: No file specified" >&2
    return 1
  fi

  shift $(( OPTIND - 1 ))

  _config::log_info info "${level}"

  if [[ "${BUTILS_LOG_TIME_FORMAT}" ]]; then
    prefix="[$(date +"${BUTILS_LOG_TIME_FORMAT}")] "
  fi

  prefix="${prefix}$(printf '%-5s' "${info[key]}") : "
  prefix="${BUTILS_COLORS[prefix]}${prefix}${BUTILS_COLORS[default]}"

  if [[ -f "${file}" ]]; then
    size=$(stat -c %s "${file}")

    if (( size > BUTILS_LOG_MAX_SIZE )); then
      local i=1

      while [[ -f "${file}.${i}" ]]; do
        (( i = i + 1 ));
      done

      mv "${file}" "${file}.${i}"
    fi
  fi

  if [[ ! -f "${file}" ]]; then
    mkdir -p "$(dirname "${file}")"
    touch "${file}"
  fi

  if (( $# > 0 )); then
    echo -e "${prefix}$(chalk -l "${info[level]}" "$@")" \
      | tee -a "${file}" >/dev/null

    return
  fi

  while read -r data; do
    echo -e "${prefix}$(chalk -l "${info[level]}" "${data}")" \
      | tee -a "${file}" >/dev/null
  done
}

function log::init() {
  declare -g _butils_log_paths=()
  local level

  for level in "${!BUTILS_LOG_LEVELS[@]}"; do
    eval "function log::${level}() {
      log -l ${level} \"\$@\"
    }"
  done
}

function log::_tee() {
  local _color="${BUTILS_COLORS[default]}"
  local flag OPTARG OPTIND

  while getopts 'c:' flag; do
    case "${flag}" in
      c) _color="${OPTARG}" ;;
      *) { echo "Invalid option provided" >&2; exit 1; } ;;
    esac
  done

  shift $(( OPTIND - 1 ))

  awk \
    -v color="${_color}" \
    -v reset="${BUTILS_COLORS[default]}" \
    '{ line=sprintf("%s%s%s", color, $0, reset); print line }' \
      | tee >(
        awk \
          -v prefix="${BUTILS_LOG_MULTILINE_PREFIX:-}" \
          '{ line= sprintf("%s%s", prefix, $0); print line}' \
          | tee -a "${_butils_log_paths[@]}" >/dev/null
      )
}
