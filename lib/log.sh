source $(dirname ${BASH_SOURCE[0]})/chalk.sh

function log() {
  local chalk=false level=info silent=false
  local flag OPTARG OPTIND

  while getopts 'cl:s' flag; do
    case "${flag}" in
      c) chalk=true ;;
      l) level="${OPTARG}" ;;
      s) silent=true ;;
    esac
  done

  shift $(( ${OPTIND} - 1 ))

  if (( $# > 0 )); then
    if [[ "${silent}" != "true" ]]; then
      chalk -l "${level}" "$@"
    fi

    if [[ "${chalk}" != "true" ]]; then
      log::write -l "${level}" "$@"
    fi

    return
  fi

  while read data; do
    if [[ "${silent}" != "true" ]]; then
      chalk -l "${level}" "${data}"
    fi

    if [[ "${chalk}" != "true" ]]; then
      log::write -l "${level}" "${data}"
    fi
  done
}

function log::write() {
  [[ -z "${BASH_UTILS_LOG_PATH}" ]] && return

  local -A level=([color]=info [severity]=info)
  local flag OPTARG OPTIND
  local prefix=""

  while getopts 'l:' flag; do
    case "${flag}" in
      l)
        case "${OPTARG}" in
          emph) level[color]=emph ;;
          error) level=([color]=error [severity]=error) ;;
          success) level[color]=success ;;
          warn | warning) level=([color]=warn [severity]=warn) ;;
        esac
        ;;
    esac
  done

  shift $(( ${OPTIND} - 1 ))

  if [[ ! -z "${BASH_UTILS_LOG_TIME_FORMAT}" ]]; then
    prefix="[$(date +"${BASH_UTILS_LOG_TIME_FORMAT}")] "
  fi

  prefix="${prefix}$(printf '%-6s' "${level[severity]}"): "
  prefix="${BASH_UTILS_COLOR_PREFIX}${prefix}${BASH_UTILS_COLOR_DEFAULT}"

  if [[ -f "${BASH_UTILS_LOG_PATH}" ]]; then
    local size=$(stat -c %s $BASH_UTILS_LOG_PATH)

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
    echo -e "${prefix}$(chalk -l "${level[color]}" "$@")" \
      | tee -a "${BASH_UTILS_LOG_PATH}" >/dev/null

    return
  fi

  while read data; do
    echo -e "${prefix}$(chalk -l "${level[color]}" "${data}")" \
      | tee -a $BASH_UTILS_LOG_PATH >/dev/null
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

  trap 'config::exit_trap $?' EXIT
}
