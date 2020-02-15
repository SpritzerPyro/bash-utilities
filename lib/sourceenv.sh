#!/bin/bash

for var in $(cat $(dirname ${BASH_SOURCE[0]:-$0})/../config/variables); do
  [[ -n ${!var+set} ]] && continue

  for path in \
    $(dirname ${BASH_SOURCE[0]:-$0})/../config/default.env \
    $(dirname ${BASH_SOURCE[0]:-$0})/../../.bashutils.env \
    $(dirname ${BASH_SOURCE[0]:-$0})/../../.env \
    $(dirname ${BASH_SOURCE[0]:-$0})/../.bashutils.env \
    $(dirname ${BASH_SOURCE[0]:-$0})/../.env \
  ; do
    [[ ! -f "$path" ]] && continue

    source <(grep -E "^$var=" $path)
  done
done
