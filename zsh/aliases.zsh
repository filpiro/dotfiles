# alias zshconfig="$EDITOR ~/.zshrc"
# alias zshconfig="$EDITOR $DOTFILES/zsh/"

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

# Exa
# alias ls='exa --group-directories-first --icons'
# alias l='ls -blF --icons'
# alias ll='ls -al --icons'
alias ls='exa --group-directories-first'
alias l='ls -blF'
alias ll='ls -al'
alias llm='ll --sort=modified'
alias la='ls -abghilmu'
alias lx='ls -abghilmuHSU@'
# alias lt='exa -a -T -L=1 --icons'
alias lt='exa -a -T -L=1'

# Docker
function dex-fn {
  docker exec -it -u $UID $(docker ps --format '{{.Names}}' | grep ${1:-php}) bash
}
alias dex="dex-fn"

function dev-fn(){
  code . | docker compose up -d
}
alias dev="dev-fn"