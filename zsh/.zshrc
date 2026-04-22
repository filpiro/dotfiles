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

# Dimensione history
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history

# Scrittura immediata e condivisione tra sessioni (tmux incluso)
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# Qualità dei dati
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# Timestamp (utile per auditing)
setopt EXTENDED_HISTORY

# Evita comandi banali
setopt HIST_IGNORE_SPACE

# PATH
export PATH="/home/filippo/.lando/bin${PATH+:$PATH}"  # landopath
export PATH=/home/filippo/.opencode/bin:$PATH

# Tools
eval "$(zoxide init zsh)"

[ -f "$HOME/.local/bin/env" ] && source "$HOME/.local/bin/env"
export PATH="$HOME/.local/bin:$PATH"

if [ -f ~/.fzf.zsh ]
then 
  source ~/.fzf.zsh
  
  # Set up fzf key bindings and fuzzy completion
  source <(fzf --zsh)
fi

[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

export CLAUDE_CODE_NO_FLICKER=1
export DISABLE_TELEMETRY=1
