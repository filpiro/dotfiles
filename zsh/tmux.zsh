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
# Sempre split verticale 60|40. Pane sinistro: yazi (y).
# Con -c/--command <comando>: comando a sinistra, yazi a destra.
function tn-fn() {
  local repo_name cmd pane right

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
    pane=$(tmux new-session -d -P -F '#{pane_id}' -s "$repo_name")
    # split 60|40: il pane originale resta a sinistra
    # con comando: comando a sinistra, yazi a destra; senza: yazi a sinistra
    right=$(tmux split-window -h -l 40% -P -F '#{pane_id}' -t "$pane")
    if [[ -n "$cmd" ]]; then
      tmux send-keys -t "$right" y C-m
    fi
    tmux send-keys -t "$pane" "${cmd:-y}" C-m
    tmux select-pane -t "$pane"
  fi

  [[ -n "$TMUX" ]] && tmux switch-client -t "=$repo_name" || tmux attach -t "=$repo_name"
}

alias tn='tn-fn'
alias tnc='tn-fn -c claude'
alias tnx='tn-fn -c codex'