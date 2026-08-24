# Krailynd-dotfile

Sanitized dotfiles for Ubuntu Server — student-safe, zero real secrets.

## Structure

```
Krailynd-dotfile/
├── install.sh
├── ubuntu-server/
│   ├── shell/       # zsh, bash, p10k, git
│   ├── tmux/        # tmux.conf
│   ├── config/      # btop, opencode, gh, ssh, atuin, himalaya
│   ├── tools/       # hermes-* bridges and helpers
│   ├── skills/      # 215 skills (192 hermes + 23 opencode), sanitized — see skills/README.md
│   ├── mcp/         # MCP servers (codegraph, engram) — opencode.json.example sanitized
│   ├── infra/       # Caddy, Docker Compose stacks, scripts, env templates
│   └── docs/        # SECURITY, STUDENT-GUIDE
└── ubuntu-server/proyectos/_template  # new project scaffold
```

## Quickstart

```bash
git clone https://github.com/<you>/Krailynd-dotfile.git
cd Krailynd-dotfile
./install.sh            # copies *.example -> real dotfiles, prompts for secrets
# or with GNU Stow:
# stow ubuntu-server -t ~
```

## Secrets

Never store secrets in this repo. Use one of:

- **AliasVault** (self-hosted, vault.sahacloud.dpdns.org)
- **sops + age** (`sops --age <pubkey> env/core.env`)
- **Environment variables** exported from `~/.hermes/.env` (gitignored)

All `*.example` files use `REPLACE_WITH_*` / `YOUR_*_KEY` placeholders.

## License

MIT — use freely, learn openly.
