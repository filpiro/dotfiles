#!/usr/bin/env bash
# Sidebar: 25-column pane on the left of every window that lists all Sessions
# (see CONTEXT.md). One Sidebar pane per window, so every attached client
# sees its own Session highlighted.
#
# Usage: sidebar.sh init            hook new windows + add Sidebar to all windows
#        sidebar.sh ensure [window] add Sidebar where missing (default: all windows)
#        sidebar.sh render          loop run inside the Sidebar pane
set -u
SELF=$(realpath "$0")
WIDTH=25

ensure() {
  local win panes
  for win in ${1:-$(tmux list-windows -a -F '#{window_id}')}; do
    # window already gone (hook fired for its last pane)
    panes=$(tmux list-panes -t "$win" -F '#{pane_start_command}' 2>/dev/null) || continue
    # Sidebar panes are recognised by their start command, set atomically at split
    grep -q 'sidebar.sh.* render' <<<"$panes" && continue
    tmux split-window -hbfd -l $WIDTH -t "$win" "exec '$SELF' render"
  done
}

render() {
  local panes width zoomed me active sel= key rest names i s
  tput civis
  # keys typed between reads would otherwise be echoed (^[[A)
  stty -echo
  # Keys (when the Sidebar pane has focus, e.g. M-Left): j/k or Down/Up move, Enter switches Session.
  while IFS=$'\t' read -r panes width zoomed me active < <(tmux display -p -t "$TMUX_PANE" \
    $'#{window_panes}\t#{pane_width}\t#{window_zoomed_flag}\t#{session_name}\t#{pane_active}'); do
    # last non-Sidebar pane gone: exit so the window closes too
    (( panes > 1 )) || exit 0
    # resize-pane would unzoom the window, so skip while zoomed
    (( width == WIDTH || zoomed )) || tmux resize-pane -t "$TMUX_PANE" -x $WIDTH
    mapfile -t names < <(tmux list-sessions -F '#{session_name}' | sort -f)
    # without focus, or when the selected Session is gone, selection follows the current Session
    [[ $active == 1 && " ${names[*]} " == *" $sel "* && -n $sel ]] || sel=$me
    printf '\e[H\e[J'
    for i in "${!names[@]}"; do
      s=${names[i]}
      if [[ $s == "$sel" && $active == 1 ]]; then printf '\e[7m'; elif [[ $s == "$me" ]]; then printf '\e[1;35m'; fi
      printf '%.*s\e[0m\n' $((WIDTH - 1)) "$s"
    done
    # ponytail: Session names with spaces break the " name " membership test above
    IFS= read -rsn1 -t 1 key || continue
    [[ $key == $'\e' ]] && { IFS= read -rsn2 -t 0.05 rest; key+=$rest; }
    for i in "${!names[@]}"; do [[ ${names[i]} == "$sel" ]] && break; done
    case $key in
      j|$'\e[B'|$'\eOB') sel=${names[i + 1 < ${#names[@]} ? i + 1 : i]} ;;
      k|$'\e[A'|$'\eOA') sel=${names[i > 0 ? i - 1 : 0]} ;;
      '') # Enter: hand focus back to the work pane so it is there on return
        tmux select-pane -t "$TMUX_PANE" -R
        tmux switch-client -t "=$sel" ;;
    esac
  done
}

init() {
  local hook
  # window-linked fires for new-window, new-session and break-pane;
  # pane-exited and after-kill-pane bring back a Sidebar that was closed
  for hook in window-linked pane-exited after-kill-pane; do
    tmux set-hook -g $hook "run-shell -b \"'$SELF' ensure #{hook_window}\""
  done
  ensure
}

"$@"
