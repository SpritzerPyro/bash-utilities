function check::email() {
  [[ "$1" =~ ^[^[:space:]]+@[^[:space:]]+$ ]]
}

function check::false() {
  [[ "$1" == "0" ]] || [[ "$1" == "false" ]]
}

function check::true() {
  [[ "$1" == "1" ]] || [[ "$1" == "true" ]]
}
