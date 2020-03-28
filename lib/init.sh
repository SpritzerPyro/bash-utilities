function butils::init() {
  butils::import config

  config::source
}

function butils::import() {
  local -r lib_dir=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")

  case "$1" in
    chalk)
      source "${lib_dir}/log.sh"
      chalk::init
      ;;
    log)
      source "${lib_dir}/log.sh"
      log::set "${BASH_UTILS_LOG_PATH}"
      ;;
    *)
      if [[ ! -f "${lib_dir}/$1.sh" ]]; then
        echo "lib::load: Library $1 does not exist" >&2
        return 1
      fi

      source "${lib_dir}/$1.sh"
      ;;
  esac
}

butils::init
