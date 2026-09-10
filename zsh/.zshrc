# Vanilla zsh. No framework.

ZDOTFILES="$HOME/.config/zsh"

# --- History ---------------------------------------------------------------
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history

setopt APPEND_HISTORY INC_APPEND_HISTORY SHARE_HISTORY
setopt HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_VERIFY
setopt EXTENDED_HISTORY HIST_IGNORE_SPACE

# --- Shell behaviour (was provided by oh-my-zsh lib/) ----------------------
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_MINUS
setopt INTERACTIVE_COMMENTS
setopt COMPLETE_IN_WORD ALWAYS_TO_END AUTO_MENU
unsetopt MENU_COMPLETE FLOW_CONTROL

zle_highlight+=(paste:none)

# --- Completion ------------------------------------------------------------
# ponytail: rebuild the dump at most once a day instead of on every shell.
autoload -Uz compinit
() {
  local dump=${ZDOTDIR:-$HOME}/.zcompdump
  if [[ -n $dump(#qN.mh+24) ]]; then
    compinit -d $dump
    { zcompile -R -- $dump.zwc $dump } &!
  else
    compinit -C -d $dump
  fi
}

zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path ~/.cache/zsh
zstyle ':completion:*:*:kill:*:processes' command 'ps -u $USER -o pid,user,comm -w -w'

# --- Prompt: folder (branch) ----------------------------------------------
autoload -Uz vcs_info add-zsh-hook
zstyle ':vcs_info:*' enable git
# NB: vcs_info substitutes every %b in these, so the bold-off lives in $PROMPT
zstyle ':vcs_info:git:*' formats '%F{cyan}%B(%b)'
zstyle ':vcs_info:git:*' actionformats '%F{cyan}%B(%b|%a)'
add-zsh-hook precmd vcs_info
setopt PROMPT_SUBST
PROMPT='%F{green}%B➜ %F{blue}%c %f%b${vcs_info_msg_0_}%f%b '

# --- PATH ------------------------------------------------------------------
typeset -U path  # keep $PATH free of duplicates
path=(
  $HOME/.local/bin
  $HOME/.lando/bin
  $HOME/.opencode/bin
  $HOME/.cargo/bin
  $HOME/.fzf/bin
  $path
)

# --- nvm (lazy) ------------------------------------------------------------
# Sourcing nvm.sh costs ~800ms. Put the default version's bin on PATH now and
# only source nvm.sh when `nvm` itself is called.
# ponytail: no .nvmrc auto-switching on cd; run `nvm use` if a repo needs it.
export NVM_DIR="$HOME/.nvm"
() {
  local v=($NVM_DIR/versions/node/*(/Nn))
  (( $#v )) && export PATH="${v[-1]}/bin:$PATH"
}
nvm() {
  unset -f nvm
  source "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
  nvm "$@"
}

# --- Config ----------------------------------------------------------------
for f in $ZDOTFILES/*.zsh(N); do source $f; done

# --- Tools -----------------------------------------------------------------
# Spawning a binary is ~100x slower on WSL than sourcing a file, so cache the
# init scripts and regenerate only when the binary is newer than the cache.
# ponytail: `rm -rf ~/.cache/zsh` after any upgrade that changes an init script.
cached_eval() {  # cached_eval <name> <command...>
  local c=~/.cache/zsh/$1.zsh b=${commands[$2]}
  [[ -n $b ]] || return
  [[ -s $c && $c -nt $b ]] || { mkdir -p ${c:h}; "${@:2}" > $c }
  source $c
}
cached_eval zoxide zoxide init zsh
cached_eval fzf fzf --zsh
source $ZDOTFILES/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null

export BASH_MAX_OUTPUT_LENGTH=1500
