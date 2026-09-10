bindkey -e

# Esc Esc: toggle `sudo` on the current line (was oh-my-zsh's sudo plugin)
function sudo-command-line() {
  [[ -z $BUFFER ]] && zle up-history
  if [[ $BUFFER == sudo\ * ]]; then
    LBUFFER="${LBUFFER#sudo }"
  else
    LBUFFER="sudo $LBUFFER"
  fi
}
zle -N sudo-command-line
bindkey '\e\e' sudo-command-line

# Up/Down search history for what is already typed
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# Home/End/Delete, in the encodings WezTerm and tmux actually send
bindkey '^[[H' beginning-of-line; bindkey '^[[1~' beginning-of-line
bindkey '^[[F' end-of-line;       bindkey '^[[4~' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[^?' backward-kill-word
