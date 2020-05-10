function chalk() {
  local color="${BASH_UTILS_COLOR_INFO}"
  local default_color="${BASH_UTILS_COLOR_DEFAULT}"
  local flags=(-e)
  local OPTARG OPTIND i

  while getopts 'l:n' flag; do
    case "${flag}" in
      l)
        for i in ${!BASH_UTILS_LOG_COLORS[@]}; do
          [[ "${i}" != "${OPTARG}" ]] && continue

          color="${BASH_UTILS_LOG_COLORS["${i}"]}"
        done
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
