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

function dev-fn(){
  local CONTAINERS=$(docker ps --format '{{.Names}}')
  [ -n "$CONTAINERS" ] && echo "Stopping running containers..." && docker stop $(docker ps --format '{{.Names}}')
  code . | docker compose up -d
}
alias dev="dev-fn"

function dev-lando-fn(){
  code . | lando start
}
alias devl="dev-lando-fn"