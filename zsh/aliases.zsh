# alias zshconfig="$EDITOR ~/.zshrc"
# alias zshconfig="$EDITOR $DOTFILES/zsh/"
export EDITOR='code'

export DOTFILES="$HOME/.dotfiles"

alias dfconfig="$EDITOR ~/.dotfiles"
alias ohmyzsh="$EDITOR ~/.oh-my-zsh"

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
  echo "Stopping running containers..."
  docker stop $(docker ps --format '{{.Names}}')
  code . | docker compose up -d
}
alias dev="dev-fn"