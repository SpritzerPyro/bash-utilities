function log() {
  local flag OPTARG OPTIND
  local level="info"

  while getopts 'l:' flag; do
    case "${flag}" in
      l) level="${OPTARG}" ;;
    esac
  done

  shift $(( ${OPTIND} - 1 ))

  if (( $# > 0 )); then
    chalk -l "${level}" "$@"
    log::write -l "${level}" "$@"

    return
  fi

  while read data; do
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

  exec 2> >(while read line; do echo "${line}" | log -l error; done)

  trap 'log::exit_trap $?' EXIT
}

function log::exit_trap() {
  [[ "$1" == "0" ]] && return 0

  IFS=' ' read -ra caller_array <<< "$(caller)"
  caller_path=$(readlink -f "${caller_array[1]}")

  echo "${caller_path} exited with code $1" | log -l error
}

function log::is_set() {
  local data=$(readlink -m "$1")
  local i

  for i in "${_butils_log_paths[@]}"; do
    local path=$(readlink -m "${i}")

    [[ "${data}" == "${path}" ]] && return 0
  done

  return 1
}

function log::native() {
  local -r info="${@:-"command"}"

  log::write "[Run] ${info}"
  tee -a "${_butils_log_paths[@]}"
  log::write "[Done] ${info}"
}

function log::set() {
  declare -g _butils_log_paths=()

  log::add "$@"
}

function log::write() {
  local path

  for path in "${_butils_log_paths[@]}"; do
    log::write_file -f "${path}" "$@"
  done
}

function log::write_file() {
  local flag OPTARG OPTIND
  local -A info
  local file
  local level="info"
  local prefix=""

  while getopts 'f:l:' flag; do
    case "${flag}" in
      f) file="${OPTARG}" ;;
      l)
        [[ "${OPTARG}" == "off" ]] && return 0

        level="${OPTARG}"
        ;;
    esac
  done

  if [[ ! "${file}" ]]; then
    echo "log::write_file: No file specified" >&2
    return 1
  fi

  shift $(( ${OPTIND} - 1 ))

  config::log_info info "${level}"

  if [[ ! -z "${BUTILS_LOG_TIME_FORMAT}" ]]; then
    prefix="[$(date +"${BUTILS_LOG_TIME_FORMAT}")] "
  fi

  prefix="${prefix}$(printf '%-5s' "${info[key]}") : "
  prefix="${BUTILS_COLOR_PREFIX}${prefix}${BUTILS_COLOR_DEFAULT}"

  if [[ -f "${file}" ]]; then
    local size=$(stat -c %s "${file}")

    if (( ${size} > ${BUTILS_LOG_MAX_SIZE} )); then
      local i=1

      while [[ -f "${file}.${i}" ]]; do
        (( i = i + 1 ));
      done

      mv "${file}" "${file}.${i}"
    fi
  fi

  if [[ ! -f "${file}" ]]; then
    mkdir -p $(dirname "${file}")
    touch "${file}"
  fi

  if (( $# > 0 )); then
    echo -e "${prefix}$(chalk -l "${info[level]}" "$@")" \
      | tee -a "${file}" >/dev/null

    return
  fi

  while read data; do
    echo -e "${prefix}$(chalk -l "${info[level]}" "${data}")" \
      | tee -a "${file}" >/dev/null
  done
}

function log::init() {
  declare -g _butils_log_paths=()
  local color

  for color in ${!BUTILS_LOG_COLORS[@]}; do
    eval "function log::${color}() {
      log -l ${color} \"\$@\"
    }"
  done
}
