function butils::init() {
  butils::import config
}

function butils::import() {
  local -r lib_dir=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")

  case "$1" in
    chalk)
      source "${lib_dir}/log.sh"
      chalk::init
      ;;
    config)
      source "${lib_dir}/config.sh"
      config::init
      config::source
      ;;
    log)
      source "${lib_dir}/chalk.sh"
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
