# Docker
alias dcup="docker compose up -d"
alias dcstop="docker compose stop"

function dev-restart-fn(){
  docker compose down
  docker compose up -d --build
}
alias dcrestart="dev-restart-fn"

function dex-fn {
  docker exec -it -u $UID $(docker ps --format '{{.Names}}' | grep ${1:-php}) bash
}
alias dex="dex-fn"