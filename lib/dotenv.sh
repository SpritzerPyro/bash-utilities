function dotenv::grep() {
  local flag OPTARG OPTIND
  local flags=(--directories='skip' --extended-regexp --no-filename)
  local var_regex="[a-zA-Z_]+[a-zA-Z0-9_]*"

  while getopts 'isv:' flag; do
    case "${flag}" in
      i) flags+=(--ignore-case) ;;
      s) flags+=(--no-messages) ;;
      v) var_regex="${OPTARG}" ;;
    esac
  done

  shift $(( ${OPTIND} - 1 ))

  if [[ -z "$@" ]] && [[ "${flags[@]}" =~ "--no-messages" ]]; then
    echo "dotenv::grep: No files specified" >&2

    return 1
  fi

  local regex="^\s*(export\s+)?${var_regex}="
  local res=$(grep "${flags[@]}" "${regex}" ${@:-""} || echo "")

  echo "${res}" | sed -E 's/^\s*(export\s+)?//'
}

function dotenv::source() {
  local -r allexport_state=$(_config::arg_state allexport)
  local flag OPTARG OPTIND
  local allexport=0
  local grep_flags=()

  while getopts 'aisv:' flag; do
    case "${flag}" in
      a) allexport=1 ;;
      i|s) grep_flags+=("-${flag}") ;;
      v) grep_flags+=("-v${OPTARG}") ;;
    esac
  done

  shift $(( ${OPTIND} - 1 ))

  if (( ${allexport} )); then
    set -a;
  fi

  source <(dotenv::grep "${grep_flags[@]+"${grep_flags[@]}"}" "$@")

  if [[ "${allexport_state}" == "off" ]]; then
    set +a;
  fi
}
