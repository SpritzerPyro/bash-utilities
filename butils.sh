function butils::init() {
  local flag OPTARG OPTIND

  butils::use config

  while getopts 'au:' flag; do
    case "${flag}" in
      a)
        for i in chalk checks dotenv log query; do
          butils::use "${i}"
        done
        ;;
      u) butils::use "${OPTARG}" ;;
      *) echo "Invalid flag: ${flag}" >&2 ;;
    esac
  done
}

function butils::use() {
  local -r lib_dir="$(
    cd -- "$(dirname "${BASH_SOURCE[0]}")/lib" || exit
    pwd
  )"

  case "$1" in
    chalk | chalks)
      source "${lib_dir}/chalk.sh"
      chalk::init
      ;;
    check | checks)
      source "${lib_dir}/checks.sh"
      ;;
    config | configs)
      source "${lib_dir}/config.sh"
      _config::init
      ;;
    dotenv)
      source "${lib_dir}/dotenv.sh"
      ;;
    log | logs | logging)
      source "${lib_dir}/chalk.sh"
      source "${lib_dir}/log.sh"
      log::init
      ;;
    query | queries)
      source "${lib_dir}/checks.sh"
      source "${lib_dir}/query.sh"
      ;;
    *)
      if [[ ! -f "${lib_dir}/$1.sh" ]]; then
        echo "butils::use: Library $1 does not exist" >&2
        return 1
      fi

      # shellcheck disable=SC1090
      source "${lib_dir}/$1.sh"
      ;;
  esac
}

butils::init "$@"
