# Claude Code notify hook (outside this repo)

`~/.claude/hooks/notify.sh` sends the WezTerm desktop notification (OSC 777)
for Claude Code "needs input" and "task complete" events. It also rings the
terminal bell, so the tmux Sidebar shows an Alert (red dot) for the Session.

The file is not in this repo. To reproduce, make the last lines of the script:

```bash
# Bell after the OSC: tmux passes the DCS through without ringing, so the bell
# is a separate byte. It sets the tmux bell flag (red dot in the Sidebar).
printf "%b\a" "$seq" > "$TTY"
exit 0
```

`$TTY` is the pane pty the script finds by walking up the process tree.
tmux reads the `\a` as pane output and sets the window bell flag. Visiting the
window clears it.

Wiring (already in `~/.claude/settings.json`): the `Stop` hook runs
`bash ~/.claude/hooks/notify.sh 'Claude Code' 'Task complete'` and the
`Notification` hook runs `... 'Needs your input'`.
tmux needs `set -g allow-passthrough on` (set in `tmux/tmux.conf`) for the
desktop notification, and the default `monitor-bell on` for the dot.

Check: run `sleep 2; printf '\a'` in a window of another Session. A red dot
appears next to that Session in the Sidebar.
