# Docker
function dex-fn {
  docker exec -it -u $UID $(docker ps --format '{{.Names}}' | grep ${1:-php}) bash
}
alias dex="dex-fn"