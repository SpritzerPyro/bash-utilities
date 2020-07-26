function query() {
  local flag OPTARG OPTIND
  local _answer
  local _default
  local _email=0
  local _optional=0
  local _path=0
  local _variable="input"

  while getopts 'd:eopv:' flag; do
    case "${flag}" in
      d) _default="${OPTARG}" ;;
      e) _email=1 ;;
      o) _optional=1 ;;
      p) _path=1 ;;
      v) _variable="${OPTARG}" ;;
    esac
  done

  shift $(( ${OPTIND} - 1 ))

  local _question="${@:-"Input"}"

  while true; do
    if [[ "${_default}" ]]; then
      echo -n "${_question} (${_default}): "
    elif (( ${_optional} )); then
      echo -n "${_question} (optional): "
    else
      echo -n "${_question}: "
    fi

    read _answer

    if [[ "${_default}" ]]; then
      _answer="${_answer:-"${_default}"}"
    fi

    if [[ ! "${_answer}" ]] && ! (( ${_optional} )); then
      echo "Required"

      continue
    fi

    if
      (( ${_email} )) && \
      ! check::email "${_answer}" && \
      ([[ "${_answer}" ]] || ! (( ${_optional} )))
    then
      echo "Invalid email"

      continue
    fi

    if (( "${_path}" )); then
      _answer="$(echo "${_answer}" | sed "s#^~#${HOME}#")"
    fi

    eval "${_variable}='${_answer}'"

    return
  done
}

function query::email() {
  local flag OPTARG OPTIND
  local _flags=(-e)

  while getopts 'd:ov:' flag; do
    case "${flag}" in
      d) _flags+=(-d "${OPTARG}") ;;
      o) _flags+=(-o) ;;
      v) _flags+=(-v "${OPTARG}") ;;
    esac
  done

  shift $(( ${OPTIND} - 1 ))

  query "${_flags[@]}" "$@"
}

function query::path() {
  local flag OPTARG OPTIND
  local _flags=(-p)

  while getopts 'd:ov:' flag; do
    case "${flag}" in
      d) _flags+=(-d "${OPTARG}") ;;
      o) _flags+=(-o) ;;
      v) _flags+=(-v "${OPTARG}") ;;
    esac
  done

  shift $(( ${OPTIND} - 1 ))

  query "${_flags[@]}" "$@"
}

function query::polar() {
  local flag OPTARG OPTIND
  local _answer _default _variable

  while getopts 'nv:y' flag; do
    case "${flag}" in
      n) _default="no" ;;
      v) _variable="${OPTARG}" ;;
      y) _default="yes" ;;
    esac
  done

  shift $(( ${OPTIND} - 1 ))

  local _question="${@:-"Input"} (yes|no)"

  while true; do
    if [[ "${_default}" ]]; then
      echo -n "${_question} (${_default}): "
    else
      echo -n "${_question}: "
    fi

    read _answer

    if [[ "${_default}" ]]; then
      _answer="${_answer:-"${_default}"}"
    fi

    case "${_answer}" in
      Y|y|yes)
        if [[ "${_variable}" ]]; then
          eval "${_variable}='yes'"
        fi

        return 0
        ;;
      N|n|no)
        if [[ ! "${_variable}" ]]; then
          return 1
        fi

        eval "${_variable}='no'"

        return 0
        ;;
    esac
  done
}
