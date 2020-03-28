function chalk() {
  local flags=(-e)
  local level=info
  local OPTARG OPTIND
  
  while getopts 'l:n' flag; do
    case "${flag}" in
      l) level="${OPTARG}" ;;
      n) flags+=(-n) ;;
    esac
  done
  
  shift $(($OPTIND - 1))

  if [[ $# -gt 0 ]]; then
    case $level in
      emph) echo "${flags[@]}" "${BASH_UTILS_COLOR_EMPH}$@${BASH_UTILS_COLOR_DEFAULT}" ;;
      error) echo "${flags[@]}" "${BASH_UTILS_COLOR_ERROR}$@${BASH_UTILS_COLOR_DEFAULT}" ;;
      success) echo "${flags[@]}" "${BASH_UTILS_COLOR_SUCCESS}$@${BASH_UTILS_COLOR_DEFAULT}" ;;
      warn | warning) echo "${flags[@]}" "${BASH_UTILS_COLOR_WARN}$@${BASH_UTILS_COLOR_DEFAULT}" ;;
      *) echo "${flags[@]}" "${BASH_UTILS_COLOR_INFO}$@${BASH_UTILS_COLOR_DEFAULT}" ;;
    esac
    
    return
  fi
  
  while read data; do
    case $level in
      emph) echo "${flags[@]}" "${BASH_UTILS_COLOR_EMPH}$data${BASH_UTILS_COLOR_DEFAULT}" ;;
      error) echo "${flags[@]}" "${BASH_UTILS_COLOR_ERROR}$data${BASH_UTILS_COLOR_DEFAULT}" ;;
      success) echo "${flags[@]}" "${BASH_UTILS_COLOR_SUCCESS}$data${BASH_UTILS_COLOR_DEFAULT}" ;;
      warn | warning) echo "${flags[@]}" "${BASH_UTILS_COLOR_WARN}$data${BASH_UTILS_COLOR_DEFAULT}" ;;
      *) echo "${flags[@]}" "${BASH_UTILS_COLOR_INFO}$data${BASH_UTILS_COLOR_DEFAULT}" ;;
    esac
  done
}
