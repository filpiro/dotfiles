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

alias bat="batcat"