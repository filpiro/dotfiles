# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="dracula"

plugins=(
  sudo
  git
  random
  zipping
  zsh-autosuggestions
)

# NVM — loaded before oh-my-zsh so npm/node are available
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

source $ZSH/oh-my-zsh.sh

# Paste highlight
zle_highlight+=(paste:none)

# PATH
export PATH="/home/filippo/.lando/bin${PATH+:$PATH}"  # landopath
export PATH=/home/filippo/.opencode/bin:$PATH

# Tools
eval "$(zoxide init zsh)"

[ -f "$HOME/.local/bin/env" ] && source "$HOME/.local/bin/env"
export PATH="$HOME/.local/bin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

export CLAUDE_CODE_NO_FLICKER=1
