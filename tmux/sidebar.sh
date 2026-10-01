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
  local panes width zoomed me out s
  tput civis
  # ponytail: polls every 1s; switch to hooks if the cost ever shows up
  while IFS=$'\t' read -r panes width zoomed me < <(tmux display -p -t "$TMUX_PANE" \
    $'#{window_panes}\t#{pane_width}\t#{window_zoomed_flag}\t#{session_name}'); do
    # last non-Sidebar pane gone: exit so the window closes too
    (( panes > 1 )) || exit 0
    # resize-pane would unzoom the window, so skip while zoomed
    (( width == WIDTH || zoomed )) || tmux resize-pane -t "$TMUX_PANE" -x $WIDTH
    out=$(tmux list-sessions -F '#{session_name}' | sort -f | while IFS= read -r s; do
      if [[ $s == "$me" ]]; then printf '\e[1;35m%.*s\e[0m\n' $((WIDTH - 1)) "$s"; else printf '%.*s\n' $((WIDTH - 1)) "$s"; fi
    done)
    printf '\e[H\e[J%s' "$out"
    sleep 1
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
