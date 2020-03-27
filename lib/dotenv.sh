function dotenv::grep() {
  local OPTIND flag
  local regex="^\s*(export\s+)?[a-zA-Z_]+[a-zA-Z0-9_]*=[a-zA-Z0-9_]*"
  local flags=(--directories='skip' --extended-regexp --no-filename)

  while getopts 's' flag; do
    case "${flag}" in
      s) flags+=(--no-messages) ;;
    esac
  done

  shift $(($OPTIND - 1))

  if [[ -z "$@" ]] && (( "${#flags[@]}" < 4 )); then
    echo "dotenv::grep: No files specified" >&2
    return 1
  fi

  local res=$(grep "${flags[@]}" "${regex}" ${@:-""} || echo "")

  echo "${res}" | sed -E 's/^\s*(export\s+)?//'
}

function dotenv::source() {
  local OPTIND flag
  local allexport
  local grep_flags=()
  
  while getopts 'as' flag; do
    case "${flag}" in
      a) allexport="true" ;;
      s) grep_flags+=(-s) ;;
    esac
  done
  
  shift $(($OPTIND - 1))

  if [[ "${allexport}" == "true" ]]; then set -a; fi

  source <(dotenv::grep "${grep_flags[@]}" "${@}")

  if [[ "${allexport}" == "true" ]]; then set +a; fi
}
