# alias zshconfig="$EDITOR ~/.zshrc"
# alias zshconfig="$EDITOR $DOTFILES/zsh/"
export EDITOR='vim'

export DOTFILES="$HOME/.dotfiles"

alias dfconfig="code ~/.dotfiles"
alias ohmyzsh="code ~/.oh-my-zsh"

alias reload="omz reload"
alias cl="clear"

function ex-fn {
  explorer.exe ${1:-.}
}
alias ex="ex-fn"

# DotBot
function dotbot-fn {
  $HOME/.dotfiles/install
  echo "Reloading..."
  omz reload
}
alias dotbot="dotbot-fn"

function docker-all-stop(){
  
  if command -v lando 2>&1 >/dev/null 
    then lando poweroff
  fi

  local CONTAINERS=$(docker ps --format '{{.Names}}')
  [ -n "$CONTAINERS" ] && echo "Stopping running containers..." && docker stop $(docker ps --format '{{.Names}}')
}

function dev-fn(){
  docker-all-stop
  # check if exist lando.yml file
  if [ -f ".lando.yml" ]; then
    code . | lando start
    return
  fi

  code . | docker compose up -d
}

alias dev="dev-fn"

# function dev-lando-fn(){
#   docker-all-stop
#   code . | lando start
# }

# alias devl="dev-lando-fn"

alias claude-mem='bun "/home/filippo/.claude/plugins/cache/thedotmack/claude-mem/10.5.5/scripts/worker-service.cjs"'

function pws-fn() {
  local mode="command"
  local cmd=""
  local extra_args=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -c|--command)
        mode="command"
        shift
        cmd="$*"
        break
        ;;
      -f|--file)
        mode="file"
        shift
        cmd="$1"
        shift
        ;;
      -e|--encoded)
        mode="encoded"
        shift
        cmd="$1"
        shift
        ;;
      -np|--no-profile)
        extra_args+=("-NoProfile")
        shift
        ;;
      -h|--help)
        echo "Uso:"
        echo "  pws -c <comando>        Esegue comando PowerShell"
        echo "  pws -f <file.ps1>       Esegue script"
        echo "  pws -e <encoded>        Comando encoded"
        echo "  pws -np                 NoProfile"
        return 0
        ;;
      *)
        # fallback: tutto come comando
        cmd="$*"
        break
        ;;
    esac
  done

  case "$mode" in
    command)
      pwsh.exe "${extra_args[@]}" -Command "$cmd"
      ;;
    file)
      pwsh.exe "${extra_args[@]}" -File "$cmd"
      ;;
    encoded)
      pwsh.exe "${extra_args[@]}" -EncodedCommand "$cmd"
      ;;
    *)
      echo "Modalità non valida"
      return 1
      ;;
  esac
}

alias pws="pws-fn"

alias claude-mem='bun "/home/filippo/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'
