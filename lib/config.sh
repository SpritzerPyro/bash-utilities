function config::exit_trap() {
  [[ $1 == "0" ]] && return 0

  IFS=' ' read -ra caller_array <<< "$(caller)"
  caller_path=$(readlink -f ${caller_array[1]})

  echo "$caller_path exited with code $1" | log -l error
}

function config::source() {
  local -r butils_dir=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")/..")

  source "${butils_dir}/lib/dotenv.sh"

  for var in $(cat "${butils_dir}/config/variables"); do
    [[ -n "${!var+set}" ]] && continue

    dotenv::source -s -v "${var}" \
      "${butils_dir}/config/default.env" \
      "${butils_dir}/../.bashutils.env" \
      "${butils_dir}/../.env" \
      "${butils_dir}/.bashutils.env" \
      "${butils_dir}/.env"
  done
}
