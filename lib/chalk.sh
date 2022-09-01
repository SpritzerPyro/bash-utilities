function chalk() {
  local flag OPTARG OPTIND
  local -A info
  local flags=(-e)
  local level="info"

  while getopts 'l:n' flag; do
    case "${flag}" in
      l) level="${OPTARG}" ;;
      n) flags+=("-${flag}") ;;
      *) { echo "Invalid option provided" >&2; return 1; } ;;
    esac
  done

  shift $(( OPTIND - 1 ))

  _config::log_info info "${level}"

  if (( "$#" > 0 )); then
    echo "${flags[@]}" "${info[color]}$*${BUTILS_COLORS[default]}"
  else
    while read -r data; do
      echo "${flags[@]}" "${info[color]}${data}${BUTILS_COLORS[default]}"
    done
  fi
}

function chalk::init() {
  local level

  for level in "${!BUTILS_LOG_LEVELS[@]}"; do
    eval "function chalk::${level}() {
      local flags=(-l ${level})
      local OPTIND

      while getopts 'n' flag; do
        case \"\${flag}\" in
          n) flags+=(\"-\${flag}\") ;;
          *) { echo \"Invalid option provided2\" >&2; return 1; } ;;
        esac
      done

      shift \$(( \${OPTIND} - 1 ))

      chalk \"\${flags[@]}\" \"\$@\"
    }"
  done
}
