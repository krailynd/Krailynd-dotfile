# archlinux-krai

Personal Arch Linux desktop dotfiles for Krai — sanitized copy of the live
machine configs (`zsh` + powerlevel10k, `tmux`, Alacritty, nvim/LazyVim,
opencode, and the "gentle-stack" of AI tools).

## What's inside

| Folder | Purpose |
|--------|---------|
| `shell/` | `.zshrc`, `.p10k.zsh`, `.bashrc`, `.profile`, `.gitconfig` — interactive shell (abs paths normalized to `${HOME}`) |
| `tmux/` | `.tmux.conf` (prefix `Ctrl+a`, power status bar, target prompt popup) + `.tmux-target-prompt.sh` |
| `config/alacritty/` | Miasma-themed terminal config |
| `config/atuin/` | shell history sync/search config |
| `config/btop/` | system monitor config |
| `config/gh/` | GitHub CLI — `config.yml.example`, `hosts.yml.example` (tokens sanitized) |
| `config/herdr/` | `config.toml` (kanagawa theme, agent UI settings) |
| `config/lazygit/` | lazygit config |
| `config/gga/` | Gentleman Guardian Angel code-review rules |
| `config/ssh/` | `config.example` — alias for `sahacloud` host (private key NOT included) |
| `config/opencode/` | opencode config (`opencode.json.example` with `YOUR_*` tokens), skills (26), SDD prompts, commands, plugins, tui-plugins, `secrets/README.md` |
| `nvim/` | full LazyVim config (init.lua, plugins/, lua/, snippets, spell) |
| `gentle-stack/` | gentle-ai / pi / engram wiring (templated, no tokens) |
| `scripts/` | `setup-arch.sh`, `setup-tpm.sh`, `verify.sh` |
| `docs/` | `MCP.md` (17 MCP servers), `SECRETS.md` (never-commit policy) |

## Install

```bash
git clone https://github.com/<you>/Krailynd-dotfile.git
cd Krailynd-dotfile
./install.sh archlinux-krai        # idempotent; never overwrites existing dotfiles
```

Or on a fresh Arch box, bootstrap packages + dotfiles together:

```bash
./archlinux-krai/scripts/setup-arch.sh
```

Then, manually:

1. `chsh -s /usr/bin/zsh` and `exec zsh && p10k configure`
2. Fill `YOUR_*_KEY` placeholders:
   - `~/.config/opencode/secrets/` (see `docs/SECRETS.md` and the file list in
     `config/opencode/secrets/README.md`)
   - `~/.config/gh/hosts.yml`
   - `~/.ssh/config` → point `IdentityFile` at your own key (never commit keys)
3. `tmux` then press `Ctrl+a` + `I` to install TPM plugins.

## Structure

```
archlinux-krai/
├── shell/            # .zshrc, .p10k.zsh, .bashrc, .profile, .gitconfig, .zshenv
├── tmux/             # .tmux.conf, .tmux-target-prompt.sh
├── config/
│   ├── alacritty/    atuin/   btop/   gh/   herdr/   lazygit/   gga/   ssh/
│   └── opencode/     # opencode.json.example, skills/, prompts/, commands/, plugins/, secrets/
├── nvim/             # LazyVim (init.lua, lua/, plugins/)
├── gentle-stack/
│   ├── gentle-ai/    # state.json.example, pi-codegraph.json
│   ├── pi/           # mcp.json.example, settings.json
│   └── engram/       # protocol-mode.json
├── scripts/          # setup-arch.sh, setup-tpm.sh, verify.sh
└── docs/             # MCP.md, SECRETS.md
```

## Security

See `docs/SECRETS.md`. No real tokens, keys, or credentials are committed;
sensitive files ship as `.example` templates with `YOUR_*` placeholders.
Run `./archlinux-krai/scripts/verify.sh` to double-check.
