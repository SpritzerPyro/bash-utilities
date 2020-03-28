function dotenv::grep() {
  local OPTARG OPTIND flag
  local flags=(--directories='skip' --extended-regexp --no-filename)
  local var_regex="[a-zA-Z_]+[a-zA-Z0-9_]*"

  while getopts 'isv:' flag; do
    case "${flag}" in
      i) flags+=(--ignore-case) ;;
      s) flags+=(--no-messages) ;;
      v) var_regex="${OPTARG}" ;;
    esac
  done

  shift $(($OPTIND - 1))

  if [[ -z "$@" ]] && [[ "${flags[@]}" =~ "--no-messages" ]]; then
    echo "dotenv::grep: No files specified" >&2
    return 1
  fi

  local regex="^\s*(export\s+)?${var_regex}="
  local res=$(grep "${flags[@]}" "${regex}" ${@:-""} || echo "")

  echo "${res}" | sed -E 's/^\s*(export\s+)?//'
}

function dotenv::source() {
  local OPTARG OPTIND flag
  local allexport
  local grep_flags=()

  while getopts 'aisv:' flag; do
    case "${flag}" in
      a) allexport="true" ;;
      i|s) grep_flags+=("-${flag}") ;;
      v) grep_flags+=("-v${OPTARG}") ;;
    esac
  done

  shift $(($OPTIND - 1))

  if [[ "${allexport}" == "true" ]]; then set -a; fi

  source <(dotenv::grep "${grep_flags[@]}" "$@")

  if [[ "${allexport}" == "true" ]]; then set +a; fi
}
