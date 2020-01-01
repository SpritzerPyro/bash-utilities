#!/bin/bash

source $(dirname ${BASH_SOURCE[0]})/colors.env
source $(dirname ${BASH_SOURCE[0]})/sourceenv.sh

function echo_emph() {
  echo -e "${BASH_UTILS_EMPH_COLOR}$@${BASH_UTILS_DEFAULT_COLOR}"
}

function echo_error() {
  echo -e "${BASH_UTILS_ERROR_COLOR}$@${BASH_UTILS_DEFAULT_COLOR}"
}

function echo_info() {
  echo -e "${BASH_UTILS_INFO_COLOR}$@${BASH_UTILS_DEFAULT_COLOR}"
}

function echo_prefix() {
  local prefix="[$(date "+%F %T")]"
  echo -e "${BASH_UTILS_PREFIX_COLOR}$prefix $@${BASH_UTILS_DEFAULT_COLOR}"
}

function echo_success() {
  echo -e "${BASH_UTILS_SUCCESS_COLOR}$@${BASH_UTILS_DEFAULT_COLOR}"
}

function echo_warn() {
  echo -e "${BASH_UTILS_WARN_COLOR}$@${BASH_UTILS_DEFAULT_COLOR}"
}
