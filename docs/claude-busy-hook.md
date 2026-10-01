# Claude Code busy hooks (outside this repo)

The tmux Sidebar shows **Busy** (yellow dot) for a Session while Claude Code
works in one of its panes. Claude Code reports this itself through hooks in
`~/.claude/settings.json`. Those hooks set the tmux pane option `@busy` on the
pane Claude runs in. The Sidebar reads it.

The file is not in this repo. To reproduce, add these hooks under `"hooks"`:

- `UserPromptSubmit` and `PreToolUse` (no matcher), command:
  `[ -z "$TMUX_PANE" ] || tmux set -p -t "$TMUX_PANE" @busy 1`
- `Stop` and `SessionEnd`, command:
  `[ -z "$TMUX_PANE" ] || tmux set -pu -t "$TMUX_PANE" @busy`

Each entry looks like:

```json
{ "hooks": [ { "type": "command", "command": "<command>", "timeout": 5 } ] }
```

`PreToolUse` already has a `Bash` entry for `validate-bash.sh`. Add the Busy
entry as a second item in the same array.

Any other program can raise Busy with the same one-liner. Clear it with the
`-u` form. If a Session has both an Alert and Busy, the red dot wins.

`SessionEnd` clears the dot when Claude exits mid-task.

Limit: if Claude is interrupted (Esc), `Stop` may not fire and the dot stays
until the next prompt finishes. No hook fires on interrupt.

Check: in a pane of another Session run `tmux set -p @busy 1`. A yellow dot
appears next to that Session. Run `tmux set -pu @busy` and it goes away.
