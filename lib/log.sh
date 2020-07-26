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

function log::exit_trap() {
  [[ "$1" == "0" ]] && return 0

  IFS=' ' read -ra caller_array <<< "$(caller)"
  caller_path=$(readlink -f "${caller_array[1]}")

  echo "${caller_path} exited with code $1" | log -l error
}

function log::native() {
  local -r info="${@:-"command"}"

  log::write "[Run] ${info}"
  tee -a "${BUTILS_LOG_PATH}"
  log::write "[Done] ${info}"
}

function log::set() {
  BUTILS_LOG_PATH="$@"

  exec 2> >(while read line; do echo "${line}" | log -l error; done)

  trap 'log::exit_trap $?' EXIT
}

function log::write() {
  [[ -z "${BUTILS_LOG_PATH}" ]] && return 0

  local -A info
  local flag OPTARG OPTIND
  local level="info" prefix=""

  while getopts 'l:' flag; do
    case "${flag}" in
      l)
        [[ "${OPTARG}" == "off" ]] && return 0

        level="${OPTARG}"
        ;;
    esac
  done

  shift $(( ${OPTIND} - 1 ))

  config::log_info info "${level}"

  if [[ ! -z "${BUTILS_LOG_TIME_FORMAT}" ]]; then
    prefix="[$(date +"${BUTILS_LOG_TIME_FORMAT}")] "
  fi

  prefix="${prefix}$(printf '%-5s' "${info[key]}") : "
  prefix="${BUTILS_COLOR_PREFIX}${prefix}${BUTILS_COLOR_DEFAULT}"

  if [[ -f "${BUTILS_LOG_PATH}" ]]; then
    local size=$(stat -c %s "${BUTILS_LOG_PATH}")

    if (( ${size} > ${BUTILS_LOG_MAX_SIZE} )); then
      local i=1

      while [[ -f "${BUTILS_LOG_PATH}.${i}" ]]; do
        (( i = i + 1 ));
      done

      mv "${BUTILS_LOG_PATH}" "${BUTILS_LOG_PATH}.${i}"
    fi
  fi

  if [[ ! -f "${BUTILS_LOG_PATH}" ]]; then
    mkdir -p $(dirname "${BUTILS_LOG_PATH}")
    touch "${BUTILS_LOG_PATH}"
  fi

  if (( $# > 0 )); then
    echo -e "${prefix}$(chalk -l "${info[level]}" "$@")" \
      | tee -a "${BUTILS_LOG_PATH}" >/dev/null

    return
  fi

  while read data; do
    echo -e "${prefix}$(chalk -l "${info[level]}" "${data}")" \
      | tee -a "${BUTILS_LOG_PATH}" >/dev/null
  done
}

function log::init() {
  local color

  for color in ${!BUTILS_LOG_COLORS[@]}; do
    eval "function log::${color}() {
      log -l ${color} \"\$@\"
    }"
  done
}
