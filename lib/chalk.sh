function chalk() {
  local -A level
  local OPTARG OPTIND flags=(-e)

  while getopts 'l:n' flag; do
    case "${flag}" in
      l) config::get_log_level level "${OPTARG}" ;;
      n) flags+=("-${flag}") ;;
    esac
  done

  shift $(($OPTIND - 1))

  if (( "$#" > 0 )); then
    echo "${flags[@]}" "${level[color]}$@${BASH_UTILS_COLOR_DEFAULT}"
    return
  fi

  while read data; do
    echo "${flags[@]}" "${level[color]}${data}${BASH_UTILS_COLOR_DEFAULT}"
  done
}

function chalk::init() {
  local color

  for color in ${!BASH_UTILS_LOG_COLORS[@]}; do
    eval "function chalk::${color}() {
      local flags=(-l ${color})
      local OPTIND

      while getopts 'n' flag; do
        case \"\${flag}\" in
          n) flags+=(\"-\${flag}\") ;;
        esac
      done

      shift \$(( \$OPTIND - 1 ))

      chalk \"\${flags[@]}\" \"\$@\"
    }"
  done
}
