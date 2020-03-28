function chalk() {
  local color="${BASH_UTILS_COLOR_INFO}"
  local default_color="${BASH_UTILS_COLOR_DEFAULT}"
  local flags=(-e)
  local OPTARG OPTIND

  while getopts 'l:n' flag; do
    case "${flag}" in
      l) 
        case "${OPTARG}" in
          emph) color="${BASH_UTILS_COLOR_EMPH}" ;;
          error) color="${BASH_UTILS_COLOR_ERROR}" ;;
          success) color="${BASH_UTILS_COLOR_SUCCESS}" ;;
          warn | warning) color="${BASH_UTILS_COLOR_WARN}" ;;
        esac
        ;;
      n) flags+=("-${flag}") ;;
    esac
  done

  shift $(($OPTIND - 1))

  if (( "$#" > 0 )); then
    echo "${flags[@]}" "${color}$@${default_color}"
    return
  fi

  while read data; do
    echo "${flags[@]}" "${color}${data}${default_color}"
  done
}

function chalk::init() {
  local color

  for color in emph error info success warn warning; do
    eval "function chalk::${color}() {
      local flags=(-l ${color})
      local OPTIND

      while getopts 'n' flag; do
        case \"\${flag}\" in
          n) flags+=(\"-\${flag}\") ;;
        esac
      done

      shift \$((\$OPTIND - 1))

      chalk \"\${flags[@]}\" \"\$@\"
    }"
  done
}
