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
# Con -w/--width <comando>: split verticale 70|30, comando nel pane 70%,
# apre anche "code ." in parallelo (senza aspettare tmux).
function tn-fn() {
  local repo_name cmd pane

  while [[ "$1" == -* ]]; do
    case "$1" in
      -w|--width) cmd="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  repo_name=$(git rev-parse --show-toplevel 2>/dev/null | xargs basename)
  # tmux rimpiazza "." e ":" con "_" nei nomi sessione: normalizza prima
  repo_name=${repo_name//[.:]/_}

  if [[ -z "$repo_name" ]]; then
    [[ -n "$TMUX" ]] && tmux new-session || tmux
    return
  fi

  if [[ -n "$cmd" ]]; then
    code . >/dev/null 2>&1 &!
  fi

  # ponytail: layout applicato solo alla creazione, non ad ogni attach
  # "=" e pane_id evitano che i punti nel nome repo (foo.it) siano letti da
  # tmux come target window.pane
  if ! tmux has-session -t "=$repo_name" 2>/dev/null; then
    pane=$(tmux new-session -d -P -F '#{pane_id}' -s "$repo_name")
    if [[ -n "$cmd" ]]; then
      tmux split-window -h -l 30% -t "$pane"
      # il comando va sempre nel pane piu' largo (70%), qualunque sia il lato
      pane=$(tmux list-panes -t "$pane" -F '#{pane_width} #{pane_id}' | sort -nr | head -1 | cut -d' ' -f2)
      tmux send-keys -t "$pane" "$cmd" C-m
      tmux select-pane -t "$pane"
    fi
  fi

  [[ -n "$TMUX" ]] && tmux switch-client -t "=$repo_name" || tmux attach -t "=$repo_name"
}

alias tn='tn-fn'
alias tnc='tn-fn -w claude'
alias tnx='tn-fn -w codex'