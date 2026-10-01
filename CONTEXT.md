# Dotfiles

Personal shell, terminal, and tmux setup for one developer working in many parallel tmux sessions.

## Language

### tmux workspace

**Session**:
A named tmux session, usually one per project repo.
_Avoid_: Section, workspace, project

**Sidebar**:
A narrow, always-visible column on the left of every window that lists all Sessions, like the file panel in an IDE.
_Avoid_: Panel, drawer, popup

**Alert**:
A Session state that means a program in one of its windows rang the bell, and nobody has visited that window since. Any program can raise it; an agent waiting for input is the main example. The Sidebar shows it as a red dot.
_Avoid_: Notification, badge, unread

**Busy**:
A Session state that means an agent in one of its panes is working on a prompt. Only programs that report it themselves can raise it. The Sidebar shows it as a yellow dot.
_Avoid_: Running, active, working
