# STUDENT-GUIDE

What to learn from each layer.

## Shell (`shell/`)

- **.zshrc / .bashrc**: PATH ordering, `oh-my-zsh` plugin system, `powerlevel10k` prompt, `atuin` history, `zoxide` navigation. Why `HIST_IGNORE_DUPS` and `SHARE_HISTORY` matter.
- **.p10k.zsh**: prompt segments, async rendering, why it is safe to commit (no secrets).
- **.inputrc**: readline, `enable-bracketed-paste` off for compatibility.
- **.gitconfig**: `gh` credential helper — how `gh auth git-credential` avoids storing tokens in plaintext.

## tmux (`tmux/`)

- `C-a` prefix, vi keys, mouse, 100k history, `monitor-bell` + `visual-bell` pattern for AI-task notifications.
- Status bar pills: git branch, TARGET, CPU, RAM, DOCK, IP — how `status-right` shell snippets work.

## Config (`config/`)

- **btop**: `color_theme`, `vim_keys`, `update_ms` — resource monitor without heavy dependencies.
- **opencode**: `mcp` servers (codegraph, engram) — how MCP extends the agent.
- **gh**: `config.yml` vs `hosts.yml` (hosts holds OAuth tokens — why it is gitignored).
- **ssh**: `Host` aliases, Tailscale `100.x.x.x` pattern, `IdentityFile`, `ForwardAgent`.
- **atuin**: shell history sync, `ATUIN_NOBIND`, search keybindings.
- **himalaya**: IMAP backend, `passwd-cmd` vs plaintext password.

## Tools (`tools/`)

- **Bridges** (hermes-vivaldi/zen): local HTTP server + token file — how browser automation avoids exposing CDP to network.
- **browser-ctl / zen-ctl**: CLI over bridge — open, screenshot, JS eval.
- **agentguard**: pre-exec filter — block `rm -rf /`, `curl | bash`.
- **ha_control.sh**: env-based `HA_TOKEN` — never hardcoded.
- **websrc / img***: content extraction and image helpers — composable Unix tools.

## Infra (`infra/`)

- **Caddy**: `:80` only, `auto_https off`, `admin off`, `{$PREVIEW_HASH}` basicauth, `reverse_proxy` + `header_up` — why Cloudflare Tunnel terminates TLS instead.
- **Docker Compose**: `sahacloud-net` vs `core-internal`, `mem_limit`, `healthcheck`, `env_file`, `extra_hosts: host.docker.internal`.
- **Env templates**: `REPLACE_WITH_*` — 12-factor config, why env files are chmod 600 and gitignored.
- **Scripts**: `health.sh` (loop over stacks), `update.sh` (backup → pull → restart), `start-preview.sh` (port 4400 lock, `host.docker.internal:4400`).

## Infra mental model

```
Internet → Cloudflare Tunnel → Caddy (127.0.0.1:8080) → sahacloud-net → app containers
                                    ↘ core-internal → postgres, redis (isolated)
```

Study order: shell → tmux → config → tools → infra. Each layer builds on the previous.
