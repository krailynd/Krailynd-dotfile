# ubuntu-server

Sanitized configs from the SahaCloud Ubuntu Server (VirtualBox + Docker + Caddy + Cloudflare Tunnel).

## What it contains

| Folder | Purpose |
|--------|---------|
| `shell/` | zsh, bash, p10k, git — interactive shell |
| `tmux/` | terminal multiplexer config |
| `config/` | btop, opencode, gh, ssh, atuin, himalaya — app configs |
| `tools/` | hermes-* bridges and helper scripts |
| `infra/` | Caddy, Docker Compose stacks, health/update/preview scripts, env templates |
| `docs/` | SECURITY and STUDENT-GUIDE |
| `proyectos/_template/` | minimal new-project scaffold |

## Prerequisites

- Ubuntu 22.04+ or Debian 12+
- `zsh`, `oh-my-zsh`, `powerlevel10k`, `atuin`, `zoxide`, `eza`, `bat`, `fzf`, `btop`, `tmux`
- `docker` + `docker compose` (for infra)
- `gh` (GitHub CLI, optional), `gitleaks` (secret scan, optional)

## Install

```bash
git clone https://github.com/<you>/Krailynd-dotfile.git
cd Krailynd-dotfile
./install.sh
# then edit ~/.zshrc and fill YOUR_*_KEY placeholders
exec zsh
```

Secrets go in AliasVault or `sops` — never in git.

## Notes

- vboxsf mounts (`~/SahaCloud/`) are not executable — runnable scripts live on local disk (`~/.local/share/hermes/tools/`).
- Caddy listens on `127.0.0.1:8080`, TLS via Cloudflare Tunnel.
- One preview at a time on port 4400: `~/sahacloud-infra/scripts/start-preview.sh <proyecto>`.
