#!/bin/bash

function docker_compose_service_id() {
  local config_path=""
  local service_name=${1:?"No service name provided"}

  [[ ! -z $2 ]] && local config_path="--file $2"

  docker-compose $config_path ps -q $service_name
}

function docker_compose_service_pid() {
  local service_name=${1:?"No service name provided"}
  local service_id=$(docker_compose_service_id $service_name $2)

  docker inspect --format '{{ .State.Pid }}' $service_id
}

function docker_compose_export_pid {
  local usage="Usage: docker_compose_export_pid service /export/path (/compose/yml/path)"
  local service_name=${1:?$usage}
  local export_path=${2:?$usage}
  local service_pid=$(docker_compose_service_pid $1 $3)
  
  echo $service_pid > $export_path
}
