function config::exit_trap() {
  [[ $1 == "0" ]] && return 0

  IFS=' ' read -ra caller_array <<< "$(caller)"
  caller_path=$(readlink -f ${caller_array[1]})

  echo "$caller_path exited with code $1" | log -l error
}

function config::source() {
  local butils_dir="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")/..")"

  for var in $(cat "${butils_dir}/config/variables"); do
    [[ -n "${!var+set}" ]] && continue

    for path in \
      "${butils_dir}/config/default.env" \
      "${butils_dir}/../.bashutils.env" \
      "${butils_dir}/../.env" \
      "${butils_dir}/.bashutils.env" \
      "${butils_dir}/.env" \
    ; do
      [[ ! -f "${path}" ]] && continue

      source <(grep -E "^${var}=" "${path}")
    done
  done
}
