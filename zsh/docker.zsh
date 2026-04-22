# Docker
alias dcup="docker compose up -d"
# alias dcstop="docker compose stop"

function dc-stop-fn() {
  if command -v lando >/dev/null 2>&1; then
    lando poweroff
  fi

  docker ps --format '{{.Names}}' | xargs -r docker stop
}

alias dcstop='dc-stop-fn'

function dc-restart-fn() {
  docker compose down || return
  docker compose up -d --build
}

function dex-fn() {
  local pattern="${1:-php}"
  local container

  container=$(docker ps --filter "name=$pattern" --format '{{.Names}}' | head -n1)

  [[ -z "$container" ]] && { echo "No container matching: $pattern"; return 1; }

  docker exec -it -u "$UID" "$container" bash
}
alias dex="dex-fn"