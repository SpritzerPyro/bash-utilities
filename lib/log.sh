function log() {
  local flag OPTARG OPTIND
  local level=info

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
  [[ $1 == "0" ]] && return 0

  IFS=' ' read -ra caller_array <<< "$(caller)"
  caller_path=$(readlink -f "${caller_array[1]}")

  echo "${caller_path} exited with code $1" | log -l error
}

function log::write() {
  [[ -z "${BASH_UTILS_LOG_PATH}" ]] && return

  local -A level
  local flag OPTARG OPTIND
  local arg="info" prefix=""

  while getopts 'l:' flag; do
    case "${flag}" in
      l)
        [[ "${OPTARG}" == "off" ]] && return

        arg="${OPTARG}"
        ;;
    esac
  done

  shift $(( ${OPTIND} - 1 ))

  config::get_log_level level "${arg}"

  if [[ ! -z "${BASH_UTILS_LOG_TIME_FORMAT}" ]]; then
    prefix="[$(date +"${BASH_UTILS_LOG_TIME_FORMAT}")] "
  fi

  prefix="${prefix}$(printf '%-5s' "${level[key]}") : "
  prefix="${BASH_UTILS_COLOR_PREFIX}${prefix}${BASH_UTILS_COLOR_DEFAULT}"

  if [[ -f "${BASH_UTILS_LOG_PATH}" ]]; then
    local size=$(stat -c %s "${BASH_UTILS_LOG_PATH}")

    if (( ${size} > ${BASH_UTILS_LOG_MAX_SIZE} )); then
      local i=1

      while [[ -f "${BASH_UTILS_LOG_PATH}.${i}" ]]; do
        (( i = i + 1 ));
      done

      mv "${BASH_UTILS_LOG_PATH}" "${BASH_UTILS_LOG_PATH}.${i}"
    fi
  fi

  if [[ ! -f "${BASH_UTILS_LOG_PATH}" ]]; then
    mkdir -p $(dirname "${BASH_UTILS_LOG_PATH}")
    touch "${BASH_UTILS_LOG_PATH}"
  fi

  if (( $# > 0 )); then
    echo -e "${prefix}$(chalk -l "${level[level]}" "$@")" \
      | tee -a "${BASH_UTILS_LOG_PATH}" >/dev/null

    return
  fi

  while read data; do
    echo -e "${prefix}$(chalk -l "${level[level]}" "${data}")" \
      | tee -a "${BASH_UTILS_LOG_PATH}" >/dev/null
  done
}

function log_native() {
  [[ ! -z $@ ]] && local info="'$@'"
  local info=${info:-command}

  log::write "Run $info"
  tee -a $BASH_UTILS_LOG_PATH
  log::write "Finished $info"
}

function log::set() {
  BASH_UTILS_LOG_PATH="$@"

  exec 2> >(while read line; do echo "${line}" | log -l error; done)

  trap 'log::exit_trap $?' EXIT
}

function log::init() {
  local color

  for color in ${!BASH_UTILS_LOG_COLORS[@]}; do
    eval "function log::${color}() {
      log -l ${color} \"\$@\"
    }"
  done
}
