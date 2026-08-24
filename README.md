# Krailynd-dotfile

**Student-safe dotfiles — zero real secrets.** Two curated profiles that turn any
machine into an AI-agent-driven personal workstation and home lab.

This repository is the public, sanitized home of a university student's
configuration. Every file is either a real dotfile with `${HOME}`-normalized
paths or a `*.example` template with `YOUR_*` / `REPLACE_WITH_*` placeholders —
no tokens, keys, personal IPs, or credentials ever get committed.

## What's inside

| Profile | Machine | What it configures |
|---|---|---|
| [`ubuntu-server/`](ubuntu-server/) | Ubuntu Server VM (VirtualBox) | Interactive shell (zsh/p10k/tmux/atuin), 13 helper tools, 215 AI skills (192 Hermes + 23 OpenCode), MCP wiring, and a full Docker + Caddy + Cloudflare Tunnel home-lab: Nextcloud, n8n, Home Assistant, AliasVault, Outline, Mattermost, Penpot, Excalidraw, website |
| [`archlinux-krai/`](archlinux-krai/) | Arch Linux desktop | zsh + powerlevel10k, tmux, Alacritty, WezTerm (Windows/WSL), a full LazyVim/Neovim setup, the OpenCode AI stack with 26 skills, and the gentle-stack (gentle-ai, pi, engram) |

The unifying theme is **an AI-agent-driven personal cloud for studying and
building**: the server profile runs self-hosted apps operated by Hermes/OpenCode
agents with a 215-skill library (LMS integration, exam study mode, LaTeX papers,
math solving, NotebookLM podcasts, Docker management, media, and more), and the
desktop profile is the daily coding + pentest-lab workstation that drives it.

## Quickstart

```bash
git clone https://github.com/krailynd/Krailynd-dotfile.git
cd Krailynd-dotfile
./install.sh            # interactive profile menu (ubuntu-server | archlinux-krai)
# or pick a profile directly:
./install.sh archlinux-krai
./install.sh ubuntu-server
```

`install.sh` is **idempotent and never destructive**: it copies files into
`$HOME` only when the destination does not exist, and never overwrites a working
config (Neovim setups in particular are protected). Run it again after pulling
updates to pick up newly added dotfiles.

- **Arch packages** are installed separately: `scripts/setup-arch.sh` (in the profile).
- After installing, fill the `YOUR_*` placeholders (see each profile's `README.md`),
  set your shell with `chsh`, and run `scripts/verify.sh` to confirm nothing leaked.

## Structure

```
Krailynd-dotfile/
├── install.sh                      # profile selector + idempotent install
├── ubuntu-server/                  # SahaCloud Ubuntu Server profile
│   ├── shell/                  # .zshrc, .bashrc, .p10k.zsh, .gitconfig (examples)
│   ├── tmux/                   # .tmux.conf — status pills, AI-completion bell
│   ├── config/                 # atuin, btop, gh, himalaya, opencode, ssh, fish
│   ├── tools/                  # 13 helpers: hermes-* bridges, browser-ctl, agentguard, img*
│   ├── skills/                 # 215 skills (192 hermes + 23 opencode) — see skills/README.md
│   ├── mcp/                    # MCP wiring (codegraph, engram) — sanitized
│   ├── infra/                  # Caddy, 10 docker-compose stacks, env templates, scripts
│   ├── docs/                   # SECURITY, STUDENT-GUIDE
│   └── proyectos/_template/    # new-project scaffold (README, CLAUDE.md, .gitignore)
└── archlinux-krai/                  # Arch Linux desktop profile
    ├── shell/                  # .zshrc, .p10k.zsh, .bashrc, .gitconfig (real, ${HOME})
    ├── tmux/                   # .tmux.conf + target-prompt helper (CTF target)
    ├── config/                 # alacritty, atuin, btop, gh, herdr, lazygit, gga, ssh,
    │                           # wezterm, opencode (17 MCP servers, 16 sub-agents)
    ├── nvim/                   # LazyVim — plugins, triple-terminal, spell dicts, snippets
    ├── gentle-stack/           # gentle-ai, pi, engram — templated, no secrets
    ├── scripts/                # setup-arch.sh, setup-tpm.sh, verify.sh
    └── docs/                   # MCP, SECRETS
```

## Security & secrets

Never store secrets in this repo. The supported secret homes are:

- **AliasVault** (self-hosted password manager)
- **sops + age** (`sops --age <pubkey> env/core.env`)
- **`~/.hermes/.env`** — local env file, `chmod 600`, gitignored

Guardrails:

- All `*.example` files ship with `REPLACE_WITH_*` / `YOUR_*_KEY` placeholders.
- `verify.sh` (arch profile) scans for token-shaped strings and `/home/<user>`
  leaks, checks every `.example` keeps a placeholder, and reports tool availability.
- `ubuntu-server/docs/SECURITY.md` lists the never-commit patterns (`.env`,
  `*.token`, `*.db`, `hosts.yml`, `gho_*`, `sk-*`, …); commits are scanned with
  gitleaks.
- `archlinux-krai/docs/SECRETS.md` documents the same policy for the desktop profile.

## For students

This repo is a working study artifact. [`ubuntu-server/docs/STUDENT-GUIDE.md`](ubuntu-server/docs/STUDENT-GUIDE.md)
maps each layer to what you can learn from it — shell history tuning, tmux
status-bar scripting, MCP, Caddy/TLS architecture, and 12-factor config — in a
study order from `shell → tmux → config → tools → infra`. The Hermes skill
library also ships with academic workflows: Canvas/Blackboard LMS access,
exam-study mode, LaTeX/academic paper writing, math solving, NotebookLM
podcasts, and citation management.

## License

MIT — use freely, learn openly.
