source "$(dirname "${BASH_SOURCE[0]}")/checks.sh"

function query() {
  local OPTARG OPTIND
  local qry_answer qry_default qry_email qry_optional qry_path
  local qry_variable="input"

  while getopts 'd:eopv:' flag; do
    case "${flag}" in
      d) echo $OPTARG && qry_default="${OPTARG}" ;;
      e) qry_email="true" ;;
      o) qry_optional="true" ;;
      p) qry_path="true" ;;
      v) qry_variable="${OPTARG}" ;;
    esac
  done

  shift $(($OPTIND - 1))

  local qry_question="${@:-"Input"}"

  while true; do
    if [[ ! -z "${qry_default}" ]]; then
      echo -n "${qry_question} (${qry_default}): "
    elif [[ "${qry_optional}" == "true" ]]; then
      echo -n "${qry_question} (optional): "
    else
      echo -n "${qry_question}: "
    fi

    read qry_answer

    if [[ ! -z "${qry_default}" ]]; then
      qry_answer="${qry_answer:-"${qry_default}"}"
    fi

    if [[ -z "${qry_answer}" ]] && [[ "${qry_optional}" != "true" ]]; then
      echo "Required"
      continue
    fi

    if
      [[ "${qry_email}" == "true" ]] && \
      ! check::email "${qry_answer}" && \
      ([[ ! -z "${qry_answer}" ]] || [[ "${qry_optional}" != "true" ]])
    then
      echo "Invalid email"
      continue
    fi

    if [[ "${qry_path}" == "true" ]]; then
      qry_answer="$(echo "${qry_answer}" | sed "s#^~#${HOME}#")"
    fi

    eval "${qry_variable}='${qry_answer}'"
    return
  done
}

function query::email() {
  local qry_flags=(-e)
  local OPTARG OPTIND

  while getopts 'd:ov:' flag; do
    case "${flag}" in
      d) qry_flags+=(-d "${OPTARG}") ;;
      o) qry_flags+=(-o) ;;
      v) qry_flags+=(-v "${OPTARG}") ;;
    esac
  done

  shift $(($OPTIND - 1))

  query "${qry_flags[@]}" "$@"
}

function query::path() {
  local qry_flags=(-p)
  local OPTARG OPTIND

  while getopts 'd:ov:' flag; do
    case "${flag}" in
      d) qry_flags+=(-d "${OPTARG}") ;;
      o) qry_flags+=(-o) ;;
      v) qry_flags+=(-v "${OPTARG}") ;;
    esac
  done

  shift $(($OPTIND - 1))

  query "${qry_flags[@]}" "$@"
}

function query::polar() {
  local OPTARG OPTIND
  local qry_answer qry_default qry_variable

  while getopts 'nv:y' flag; do
    case "${flag}" in
      n) qry_default="no" ;;
      v) qry_variable="${OPTARG}" ;;
      y) qry_default="yes" ;;
    esac
  done

  shift $(($OPTIND - 1))

  local qry_question="${@:-"Input"} (yes|no)"

  while true; do
    if [[ -z "${qry_default}" ]]; then
      echo -n "${qry_question}: "
    else
      echo -n "${qry_question} (${qry_default}): "
    fi

    read qry_answer

    if [[ ! -z "${qry_default}" ]]; then
      qry_answer="${qry_answer:-"${qry_default}"}"
    fi

    case "${qry_answer}" in
      Y|y|yes )
        if [[ ! -z "${qry_variable}" ]]; then
          eval "${qry_variable}='yes'"
        fi

        return 0
        ;;
      N|n|no )
        if [[ -z "${qry_variable}" ]]; then
          return 1
        fi

        eval "${qry_variable}='no'"
        return 0
        ;;
    esac
  done
}
