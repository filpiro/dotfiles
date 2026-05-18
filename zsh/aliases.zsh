# alias zshconfig="$EDITOR ~/.zshrc"
# alias zshconfig="$EDITOR $DOTFILES/zsh/"
# export EDITOR='nvim'
export EDITOR='code'

export DOTFILES="$HOME/.dotfiles"

alias dfconfig="code ~/.dotfiles"
alias ohmyzsh="code ~/.oh-my-zsh"
alias vch="code ."

alias reload="omz reload"
alias cl="clear"

# WSL utility
function ex-fn {
  explorer.exe ${1:-.}
}
alias ex="ex-fn"

alias wsl="wsl.exe"
alias pws="pwsh.exe"


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


# alias claude-mem='bun "/home/filippo/.claude/plugins/cache/thedotmack/claude-mem/10.5.5/scripts/worker-service.cjs"'
# alias claude-mem='bun "/home/filippo/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'

alias lg="lazygit"