source $(dirname ${BASH_SOURCE[0]})/chalk.sh

function log::write() {
  local level=info
  local severity=info
  local OPTIND
  local prefix=""

  while getopts 'l:s' flag; do
    case $flag in
      l)
        case $OPTARG in
          emph) level=emph ;;
          error)
            level=error
            severity=error
            ;;
          success) level=success ;;
          warn | warning)
            level=warning
            severity=warning
            ;;
          *) level=info ;;
        esac
        ;;
    esac
  done

  [[ -z $BASH_UTILS_LOG_PATH ]] && return

  shift $(($OPTIND - 1))

  if [[ ! -z "${BASH_UTILS_LOG_TIME_FORMAT}" ]]; then
    prefix="[$(date +"${BASH_UTILS_LOG_TIME_FORMAT}")] "
  fi

  prefix="$prefix$(printf '%-8s' "${severity}"): "
  prefix="${BASH_UTILS_COLOR_PREFIX}${prefix}${BASH_UTILS_COLOR_DEFAULT}"

  if [[ -f $BASH_UTILS_LOG_PATH ]]; then
    local size=$(stat -c %s $BASH_UTILS_LOG_PATH)

    if [[ $size -gt $BASH_UTILS_LOG_MAX_SIZE ]]; then
      local i=1
      while [[ -f $BASH_UTILS_LOG_PATH.$i ]]; do ((i=i+1)); done
      mv $BASH_UTILS_LOG_PATH $BASH_UTILS_LOG_PATH.$i
    fi
  fi

  if [[ ! -f $BASH_UTILS_LOG_PATH ]]; then
    mkdir -p $(dirname $BASH_UTILS_LOG_PATH)
    touch $BASH_UTILS_LOG_PATH
  fi

  if [[ $# -gt 0 ]]; then
    echo -e "$prefix$(echo $@ | chalk -l $level)" | tee -a $BASH_UTILS_LOG_PATH >/dev/null
    return
  fi

  while read data; do
    echo -e "$prefix$(echo $data | chalk -l $level)" | tee -a $BASH_UTILS_LOG_PATH >/dev/null
  done
}

function log() {
  local chalk=false
  local level=info
  local OPTIND
  local silent=false

  while getopts 'cl:s' flag; do
    case $flag in
      c) chalk=true ;;
      l) level=$OPTARG ;;
      s) silent=true ;;
    esac
  done

  shift $(($OPTIND - 1))

  if [[ $# -gt 0 ]]; then
    [[ $silent != "true" ]] && echo $@ | chalk -l $level
    [[ $chalk != "true" ]] && echo $@ | log::write -l $level
    return
  fi

  while read data; do
    [[ $silent != "true" ]] && echo $data | chalk -l $level
    [[ $chalk != "true" ]] && echo $data | log::write -l $level
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
