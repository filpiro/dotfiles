alias ta="tmux attach"
alias td="tmux detach"
alias tl="tmux ls"
alias tk="tmux kill-session"

# tn: apre una sessione tmux legata alla repo corrente.
# - Se NON sei in una repo Git → apre tmux normale
# - Se sei in una repo:
#     • fuori da tmux → attach o crea (new-session -A)
#     • dentro tmux → switch alla sessione se esiste, altrimenti la crea
# Questo evita l’errore "duplicate session" quando sei già dentro tmux.
#
# Sempre split verticale 60|40. Pane destro: yazi (y). Sinistro: shell.
# Con -c/--command <comando>: comando nel pane sinistro.
function tn-fn() {
  local repo_name cmd pane

  while [[ "$1" == -* ]]; do
    case "$1" in
      -c|--command) cmd="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  repo_name=${$(git rev-parse --show-toplevel 2>/dev/null):t}
  # tmux rimpiazza "." e ":" con "_" nei nomi sessione: normalizza prima
  repo_name=${repo_name//[.:]/_}

  if [[ -z "$repo_name" ]]; then
    [[ -n "$TMUX" ]] && tmux new-session || tmux
    return
  fi

  # ponytail: layout applicato solo alla creazione, non ad ogni attach
  # "=" e pane_id evitano che i punti nel nome repo (foo.it) siano letti da
  # tmux come target window.pane
  if ! tmux has-session -t "=$repo_name" 2>/dev/null; then
    # comando come processo del pane, non send-keys (niente eco del comando)
    # ponytail: apici singoli nel comando rompono il quoting, gestire se servono
    if [[ -n "$cmd" ]]; then
      pane=$(tmux new-session -d -P -F '#{pane_id}' -s "$repo_name" \
        "exec zsh -ic '$cmd; exec zsh'")
    else
      pane=$(tmux new-session -d -P -F '#{pane_id}' -s "$repo_name")
    fi
    # split 60|40: sinistra comando (o shell), destra sempre yazi
    tmux split-window -h -l 40% -t "$pane" "exec zsh -ic 'y; exec zsh'"
    tmux select-pane -t "$pane"
  fi

  [[ -n "$TMUX" ]] && tmux switch-client -t "=$repo_name" || tmux attach -t "=$repo_name"
}

alias tn='tn-fn'
alias tnc='tn-fn -c claude'
alias tnx='tn-fn -c codex'