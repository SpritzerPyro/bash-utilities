function chalk() {
  local -A info
  local flags=(-e) level="info" OPTARG OPTIND

  while getopts 'l:n' flag; do
    case "${flag}" in
      l) level="${OPTARG}" ;;
      n) flags+=("-${flag}") ;;
    esac
  done

  shift $(( ${OPTIND} - 1 ))

  config::log_info info "${level}"

  if (( "$#" > 0 )); then
    echo "${flags[@]}" "${info[color]}$@${BUTILS_COLOR_DEFAULT}"

    return
  fi

  while read data; do
    echo "${flags[@]}" "${info[color]}${data}${BUTILS_COLOR_DEFAULT}"
  done
}

function chalk::init() {
  local color

  for color in ${!BUTILS_LOG_COLORS[@]}; do
    eval "function chalk::${color}() {
      local flags=(-l ${color})
      local OPTIND

      while getopts 'n' flag; do
        case \"\${flag}\" in
          n) flags+=(\"-\${flag}\") ;;
        esac
      done

      shift \$(( \${OPTIND} - 1 ))

      chalk \"\${flags[@]}\" \"\$@\"
    }"
  done
}
