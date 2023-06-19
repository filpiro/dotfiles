# Docker
function dex-fn {
  docker exec -it -u $UID $(docker ps --format '{{.Names}}' | grep ${1:-php}) bash
}
alias dex="dex-fn"

function dev-fn(){
  code . | docker compose up -d
}
alias dev="dev-fn"

alias dcup="docker compose up -d"
alias dcstop="docker compose stop"