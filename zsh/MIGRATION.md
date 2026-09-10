# Zsh: Oh My Zsh → vanilla

## Startup: before → after

|            | median     | worst  |
|------------|------------|--------|
| Oh My Zsh  | **2.0 s**  | 6.6 s  |
| vanilla    | **0.36 s** | 0.77 s |

~5.5x faster. `zprof` internal time went 1500 ms → 24 ms.

Measured with `for i in {1..8}; do /usr/bin/time -f "%e" zsh -i -c exit; done`,
cold `~/.zcompdump` on both runs.

## What caused the delay (measured, not guessed)

| Cost            | Culprit                                                                   | Fix                                                                    |
|-----------------|---------------------------------------------------------------------------|------------------------------------------------------------------------|
| **820 ms (54%)** | `nvm.sh` sourcing (`nvm_auto`, `nvm_ensure_version_installed`)            | Node bin on PATH directly, `nvm` shim sources lazily on first call      |
| **318 ms**       | `_omz_source` × 26 files                                                  | Gone with OMZ                                                           |
| **341 ms**       | `compinit`/`compdump` rebuilt every shell                                 | Dump rebuilt max once/day, `zcompile`d in background                    |
| **245 ms**       | `fzf --zsh` spawn — WSL PATH has `/mnt/c/*` entries, exec is brutal       | Init output cached in `~/.cache/zsh/`                                   |
| —                | dracula theme forked `git status` async per prompt                        | `vcs_info` (zsh stdlib), branch only                                    |

**nvm was the single biggest cost and had nothing to do with Oh My Zsh.**
Removing OMZ alone would have got ~1.4 s, not 0.36 s.

## What was actually used (from `~/.zsh_history`)

| Feature                     | Verdict                                                                                       |
|-----------------------------|-----------------------------------------------------------------------------------------------|
| `take` (141 uses)           | **Implicit OMZ dependency, not in `plugins=()`.** Reimplemented, 3 lines in `functions.zsh`    |
| `gcl` (50 uses)             | OMZ git plugin alias. Copied into `git.zsh`                                                    |
| `git` typed in full (545)   | git plugin's ~180 other aliases: unused, dropped                                               |
| `docker` typed in full (108)| `docker.zsh` already covers it                                                                 |
| `rnd` (16), `zp` (4)        | **Own files**, not OMZ's — moved verbatim to `rnd.zsh`/`zip.zsh`. Already uses `/dev/urandom`  |
| `jump` (3)                  | Wasn't even enabled in `plugins=()`. Deleted                                                   |
| `omz reload`                | Replaced with `exec zsh`                                                                       |
| `zsh-autosuggestions`       | Kept — now a git submodule under `zsh/plugins/`                                                |
| Esc Esc sudo                | Reimplemented, 8 lines in `keybindings.zsh`                                                    |

Also carried over from OMZ's `lib/` (implicit, unlisted): `auto_cd`, `auto_pushd`,
case-insensitive completion matcher, `menu select`, prefix history search on ↑/↓,
Home/End/Del/Ctrl-arrow bindings.

## Layout

```
~/.zshrc                    -> zsh/.zshrc
~/.config/zsh/aliases.zsh  docker.zsh  exa.zsh  functions.zsh
               git.zsh  keybindings.zsh  npm.zsh  rnd.zsh  tmux.zsh  zip.zsh
               plugins/zsh-autosuggestions   (submodule)
```

`install.conf.yaml`: glob narrowed to `zsh/*.zsh` — plain `zsh/**` recursed into
the submodule and linked 200 files.

## Prompt

`➜ folder (branch) ` — same colors, same layout as the dracula theme.

**Dropped the ✔/✗ dirty marker.** It was the only thing forcing a full `git status`
fork every prompt. To restore it cheaply, use `git status --porcelain -uno`.

Note: `vcs_info` substitutes *every* `%b` in its format strings, so the bold-off
`%b` lives in `$PROMPT`, not in the format — otherwise the branch prints twice.

## Trade-offs

- **No `.nvmrc` auto-switch on `cd`.** Wasn't happening before either — nvm's
  `nvm_auto` only applies the default alias at startup. Run `nvm use` in repos
  needing v10.
- **`~/.cache/zsh` init cache** invalidates on binary mtime. After a manual
  fzf/zoxide upgrade that keeps the mtime: `rm -rf ~/.cache/zsh`.
- **Completion dump up to 24h stale.** A new tool's completions appear next day,
  or `rm ~/.zcompdump`.
- **No OMZ updater/plugin manager.** New plugin = `git submodule add` + one
  `source` line.

## Leftovers

`~/.oh-my-zsh/` still on disk, untouched. Verify a few days, then `rm -rf`.
