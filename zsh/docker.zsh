# Docker
alias dcup="docker compose up -d"
# alias dcstop="docker compose stop"

function dc-stop-fn(){
  
  if command -v lando 2>&1 >/dev/null 
    then lando poweroff
  fi

  docker stop $(docker ps --format '{{.Names}}')
}
alias dcstop="dc-stop-fn"

function dc-restart-fn(){
  docker compose down
  docker compose up -d --build
}
alias dcrestart="dc-restart-fn"

function dex-fn {
  docker exec -it -u $UID $(docker ps --format '{{.Names}}' | grep ${1:-php}) bash
}
alias dex="dex-fn"