#!/bin/bash

source $(dirname ${BASH_SOURCE[0]:-$0})/colors.env
source $(dirname ${BASH_SOURCE[0]:-$0})/sourceenv.sh

function chalk() {
  local level=info
  local OPTIND
  
  while getopts 'l:' flag; do
    case $flag in
      l) level=$OPTARG ;;
    esac
  done
  
  shift $(($OPTIND - 1))
  
  if [[ $# -gt 0 ]]; then
    case $level in
      emph) echo -e "${BASH_UTILS_EMPH_COLOR}$@${BASH_UTILS_DEFAULT_COLOR}" ;;
      error) echo -e "${BASH_UTILS_ERROR_COLOR}$@${BASH_UTILS_DEFAULT_COLOR}" ;;
      success) echo -e "${BASH_UTILS_SUCCESS_COLOR}$@${BASH_UTILS_DEFAULT_COLOR}" ;;
      warn | warning) echo -e "${BASH_UTILS_WARN_COLOR}$@${BASH_UTILS_DEFAULT_COLOR}" ;;
      *) echo -e "${BASH_UTILS_INFO_COLOR}$@${BASH_UTILS_DEFAULT_COLOR}" ;;
    esac
    
    return
  fi
  
  while read data; do
    case $level in
      emph) echo -e "${BASH_UTILS_EMPH_COLOR}$data${BASH_UTILS_DEFAULT_COLOR}" ;;
      error) echo -e "${BASH_UTILS_ERROR_COLOR}$data${BASH_UTILS_DEFAULT_COLOR}" ;;
      success) echo -e "${BASH_UTILS_SUCCESS_COLOR}$data${BASH_UTILS_DEFAULT_COLOR}" ;;
      warn | warning) echo -e "${BASH_UTILS_WARN_COLOR}$data${BASH_UTILS_DEFAULT_COLOR}" ;;
      *) echo -e "${BASH_UTILS_INFO_COLOR}$data${BASH_UTILS_DEFAULT_COLOR}" ;;
    esac
  done
}
