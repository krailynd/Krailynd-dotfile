# Krailynd-dotfile

Sanitized dotfiles — student-safe, zero real secrets. Two profiles:

- **`ubuntu-server`** — Ubuntu Server VM (Caddy, Docker stacks, hermes bridges, 215 skills)
- **`archlinux-krai`** — Arch Linux desktop (zsh/p10k, tmux, nvim/LazyVim, opencode, gentle-stack, WezTerm)

## Structure

```
Krailynd-dotfile/
├── install.sh            # profile selector + idempotent install
├── ubuntu-server/        # Ubuntu Server profile
│   ├── shell/       # zsh, bash, p10k, git
│   ├── tmux/        # tmux.conf
│   ├── config/      # btop, opencode, gh, ssh, atuin, himalaya
│   ├── tools/       # hermes-* bridges and helpers
│   ├── skills/      # 215 skills (192 hermes + 23 opencode), sanitized — see skills/README.md
│   ├── mcp/         # MCP servers (codegraph, engram) — opencode.json.example sanitized
│   ├── infra/       # Caddy, Docker Compose stacks, scripts, env templates
│   └── docs/        # SECURITY, STUDENT-GUIDE
├── archlinux-krai/       # Arch Linux desktop profile
│   ├── shell/       # .zshrc, .p10k.zsh, .bashrc, .gitconfig (real files, ${HOME} normalized)
│   ├── tmux/        # tmux.conf + target-prompt helper
│   ├── config/      # alacritty, atuin, btop, gh, herdr, lazygit, gga, ssh, wezterm
│   ├── nvim/        # LazyVim config + plugins
│   ├── gentle-stack/ # gentle-ai, pi, engram — templated, no secrets
│   └── scripts/     # setup-arch.sh and helpers
└── ubuntu-server/proyectos/_template  # new project scaffold
```

## Quickstart

```bash
git clone https://github.com/<you>/Krailynd-dotfile.git
cd Krailynd-dotfile
./install.sh            # interactive profile menu (ubuntu-server | archlinux-krai)
# or pick a profile directly:
./install.sh archlinux-krai
./install.sh ubuntu-server
```

`install.sh` is idempotent: it copies `*.example` -> real dotfiles and only
creates files that do not exist yet, never overwriting existing config. Run it
again after pulling updates to fill in new dotfiles.

## Secrets

Never store secrets in this repo. Use one of:

- **AliasVault** (self-hosted, vault.sahacloud.dpdns.org)
- **sops + age** (`sops --age <pubkey> env/core.env`)
- **Environment variables** exported from `~/.hermes/.env` (gitignored)

All `*.example` files use `REPLACE_WITH_*` / `YOUR_*_KEY` placeholders.

## License

MIT — use freely, learn openly.
