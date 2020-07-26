#!/bin/bash

function docker::pid() {
  local flag OPTARG OPTIND
  local -r flags=(--format '{{ .State.Pid }}')
  local target
  local write

  while getopts 's:t:w:' flag; do
    case "${flag}" in
      s|t) target="${OPTARG}" ;;
      w) write="${OPTARG}" ;;
    esac
  done

  shift $(( ${OPTIND} - 1 ))

  target="${target:-"$1"}"

  local -r pid=$(docker container inspect "${flags[@]}" "${target}")

  if [[ "${write}" ]]; then
    echo "${pid}" > "${write}"
  fi

  echo "${pid}"
}

function docker_compose::id() {
  local flag OPTARG OPTIND
  local flags=()
  local service
  local write

  while getopts 'f:s:t:w:' flag; do
    case "${flag}" in
      f) flags+=(--file "${OPTARG}") ;;
      s|t) service="${OPTARG}" ;;
      w) write="${OPTARG}" ;;
    esac
  done

  shift $(( ${OPTIND} - 1 ))

  service="${service:-"$1"}"

  local -r id=$(docker-compose "${flags[@]}" ps --quiet "${service}")

  if [[ "${write}" ]]; then
    echo "${id}" > "${write}"
  fi

  echo "${id}"
}

function docker_compose::pid {
  local flag OPTARG OPTIND
  local id_flags=()
  local pid_flags=()
  local service

  while getopts 'f:s:t:w:' flag; do
    case "${flag}" in
      f) id_flags+=(-f "${OPTARG}") ;;
      s|t) service="${OPTARG}" ;;
      w) pid_flags+=(-w "${OPTARG}") ;;
    esac
  done

  shift $(( ${OPTIND} - 1 ))

  service="${service:-"$1"}"

  local -r id=$(docker_compose::id "${id_flags[@]}" "${service}")

  docker::pid "${pid_flags[@]}" "${id}"
}
