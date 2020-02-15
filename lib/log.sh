#!/bin/bash

source $(dirname ${BASH_SOURCE[0]:-$0})/chalk.sh
source $(dirname ${BASH_SOURCE[0]:-$0})/log.env
source $(dirname ${BASH_SOURCE[0]:-$0})/sourceenv.sh

function writelog() {
  local level=info
  local OPTIND
  local prefix=""
  
  while getopts 'l:s' flag; do
    case $flag in
      l)
        case $OPTARG in
          emph) level=emph ;;
          error) level=error ;;
          success) level=success ;;
          warn | warning) level=warning ;;
          *) level=info ;;
        esac
        ;;
    esac
  done

  [[ -z $BASH_UTILS_LOG_PATH ]] && return

  shift $(($OPTIND - 1))

  [[ ! -z $BASH_UTILS_LOG_PREFIX ]] && prefix="$BASH_UTILS_LOG_PREFIX "
  prefix="$prefix$(printf '%-8s' $level): "
  prefix="${BASH_UTILS_PREFIX_COLOR}${prefix}${BASH_UTILS_DEFAULT_COLOR}"

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
    [[ $chalk != "true" ]] && echo $@ | writelog -l $level
    return
  fi

  while read data; do
    [[ $silent != "true" ]] && echo $data | chalk -l $level
    [[ $chalk != "true" ]] && echo $data | writelog -l $level
  done
}

function log_native() {
  [[ ! -z $@ ]] && local info="'$@'"
  local info=${info:-command}

  writelog "Run $info"
  tee -a $BASH_UTILS_LOG_PATH
  writelog "Finished $info"
}
