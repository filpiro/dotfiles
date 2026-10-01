#!/usr/bin/env bash
# Integration check for sidebar.sh on a throwaway tmux server.
# Usage: tmux/sidebar_test.sh
set -u
cd "$(dirname "$0")"
SOCK=sidebar-test-$$
t() { tmux -L "$SOCK" "$@"; }
trap 't kill-server 2>/dev/null' EXIT
fail=0
check() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi; }
sidebars() { t list-panes -t "$1" -F '#{pane_start_command}' | grep -c 'sidebar.sh.* render'; }
# $1 window, $2 "" for the Sidebar pane id, "!" for the other panes
sidebar_pane() { t list-panes -t "$1" -F '#{pane_id} #{pane_start_command}' | awk "${2:-}/sidebar.sh.* render/{print \$1}"; }
wait_for() { for _ in $(seq 30); do eval "$1" && return 0; sleep 0.1; done; return 1; }

t -f /dev/null new-session -d -s beta -x 200 -y 50 'sleep 600'
t new-window -d -t beta 'sleep 600'
export TMUX="$(t display -p '#{socket_path}'),0,0"
./sidebar.sh init

check "existing windows get one Sidebar" \
  '[[ $(sidebars beta:0) == 1 && $(sidebars beta:1) == 1 ]]'
check "Sidebar is leftmost and 25 columns" \
  '[[ $(t list-panes -t beta:0 -F "#{pane_left} #{pane_width} #{pane_start_command}" | grep render) == "0 25 "* ]]'

t new-session -d -s Alpha -x 200 -y 50 'sleep 600'
t new-window -d -t Alpha
t split-window -d -t Alpha:1
check "new Session and new window get one Sidebar" \
  'wait_for "[[ \$(sidebars Alpha:0) == 1 && \$(sidebars Alpha:1) == 1 ]]"'

sleep 1.5
pane=$(sidebar_pane beta:0)
screen=$(t capture-pane -p -e -t "$pane")
check "lists Sessions A to Z" '[[ $(t capture-pane -p -t "$pane" | grep -v "^$" | tr "\n" " ") == "Alpha beta " ]]'
check "current Session highlighted" '[[ $screen == *"35mbeta"* ]]'
alpha=$(sidebar_pane Alpha:0)
check "each window highlights its own Session (two clients)" \
  '[[ $(t capture-pane -p -e -t "$alpha") == *"35mAlpha"* ]]'

./sidebar.sh init
check "re-running init adds no second Sidebar" '[[ $(sidebars beta:0) == 1 ]]'

t new-session -d -s gamma -x 200 -y 50
check "new Session appears within ~1s" 'wait_for "t capture-pane -p -t $pane | grep -q gamma"'
t kill-session -t gamma
check "killed Session disappears within ~1s" 'wait_for "! t capture-pane -p -t $pane | grep -q gamma"'

t kill-pane -t "$(sidebar_pane Alpha:1)"
check "killed Sidebar comes back" 'wait_for "[[ \$(sidebars Alpha:1) == 1 ]]"'

all_sidebars() { t list-panes -a -F '#{pane_start_command}' | grep -c 'sidebar.sh.* render'; }
./sidebar.sh toggle
check "toggle hides every Sidebar" 'wait_for "[[ \$(all_sidebars) == 0 ]]"'
t new-window -d -t Alpha
sleep 1
check "new window stays without Sidebar while hidden" '[[ $(all_sidebars) == 0 ]]'
./sidebar.sh toggle
check "toggle shows a Sidebar in every window" 'wait_for "[[ \$(all_sidebars) == \$(t list-windows -a | wc -l) ]]"'
pane=$(sidebar_pane beta:0) # toggle made a new one

t kill-pane -t "$(sidebar_pane beta:1 !)"
check "window closes when only Sidebar left" 'wait_for "[[ \$(t list-windows -t beta | wc -l) == 1 ]]"'


# Move and switch need an attached client: run one inside a pty
script -qfc "tmux -L $SOCK attach -t beta" /dev/null </dev/null >/dev/null 2>&1 &
wait_for '[[ -n $(t list-clients) ]]'
t select-pane -t "$pane"
t send-keys -t "$pane" j
check "j moves the highlight to the next Session" \
  'wait_for "[[ \$(t capture-pane -p -e -t $pane | grep -c \"7m\") == 1 && \$(t capture-pane -p -e -t $pane) == *\"7mbeta\"* ]]"'
t send-keys -t "$pane" k
check "k moves the highlight back" 'wait_for "t capture-pane -p -e -t $pane | grep -q \"7mAlpha\""'
t send-keys -t "$pane" Enter
check "Enter switches the client to that Session" 'wait_for "[[ \$(t list-clients -F \"#{client_session}\") == Alpha ]]"'
check "Enter leaves focus in the work pane" '[[ $(t display -p -t "$pane" "#{pane_active}") == 0 ]]'

exit $fail
