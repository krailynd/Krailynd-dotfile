#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Profile selector (ubuntu-server | archlinux-krai) ---
CHOICE=""
if [ "${1:-}" = "ubuntu-server" ] || [ "${1:-}" = "archlinux-krai" ]; then
  CHOICE="$1"
elif [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  echo "Usage: ./install.sh [ubuntu-server|archlinux-krai]"
  echo "  No arg -> interactive menu"
  exit 0
else
  echo "==> Krailynd-dotfile — select profile"
  echo "  1) ubuntu-server  — Ubuntu Server VM (Caddy, Docker stacks, hermes bridges)"
  echo "  2) archlinux-krai — Arch Linux desktop (zsh/p10k, tmux, nvim/LazyVim, opencode, gentle-stack)"
  echo ""
  printf "Choose [1/2] (default 1): "
  read -r sel
  case "${sel:-1}" in
    1|ubuntu*|u|U) CHOICE="ubuntu-server" ;;
    2|arch*|a|A)   CHOICE="archlinux-krai" ;;
    *) echo "Invalid choice: $sel" >&2; exit 1 ;;
  esac
fi

SRC="$REPO_DIR/$CHOICE"
echo ""
echo "==> Krailynd-dotfile bootstrap"
echo "    Profile: $CHOICE"
echo "    Source:  $SRC"
echo ""

if [ ! -d "$SRC" ]; then
  echo "[!] Profile directory not found: $SRC" >&2
  exit 1
fi

need_cmd() { command -v "$1" >/dev/null 2>&1 || echo "  [!] $1 not found — install it first"; }

echo "==> Prerequisites check"
need_cmd zsh
need_cmd tmux
need_cmd git
if [ "$CHOICE" = "ubuntu-server" ]; then
  need_cmd docker
elif [ "$CHOICE" = "archlinux-krai" ]; then
  need_cmd hyprctl || echo "  [!] hyprctl not found — Hyprland not installed"
  need_cmd nvim || echo "  [!] neovim not found — LazyVim needs it (see archlinux-krai/scripts/setup-arch.sh)"
  need_cmd alacritty || echo "  [!] alacritty not found — config ships anyway"
fi
echo "    OK — missing tools shown above (optional)"
echo ""

# Copy a single file to $HOME only when the destination does not exist.
install_example() {
  local src="$1" dst="$2"
  if [ -f "$dst" ]; then
    echo "  skip $dst (already exists)"
  elif [ -f "$src" ]; then
    cp "$src" "$dst"
    echo "  created $dst (from $(basename "$src"))"
  fi
}

# Copy a directory tree to $HOME, file-by-file, never overwriting anything.
install_tree() {
  local src="$1" dst="$2"
  [ -d "$src" ] || return 0
  mkdir -p "$dst"
  local copied=0 skipped=0
  while IFS= read -r -d '' f; do
    local rel="${f#"$src"/}"
    local target="$dst/$rel"
    if [ -e "$target" ]; then
      skipped=$((skipped + 1))
    else
      mkdir -p "$(dirname "$target")"
      cp "$f" "$target"
      copied=$((copied + 1))
    fi
  done < <(find "$src" -type f -print0)
  echo "  $copied created, $skipped skipped (already present) -> $dst"
}

# ---------------------------------------------------------------- archlinux-krai
install_archlinux_krai() {
  echo "==> shell/ (real files — copied verbatim, ${HOME} normalized)"
  mkdir -p "$HOME"
  for f in .zshrc .p10k.zsh .bashrc .bash_profile .profile .gitconfig .zshenv; do
    install_example "$SRC/shell/$f" "$HOME/$f"
  done

  echo ""
  echo "==> tmux/"
  install_example "$SRC/tmux/.tmux.conf" "$HOME/.tmux.conf"
  install_example "$SRC/tmux/.tmux-target-prompt.sh" "$HOME/.tmux-target-prompt.sh"
  [ -f "$HOME/.tmux-target-prompt.sh" ] && chmod +x "$HOME/.tmux-target-prompt.sh"

  echo ""
  echo "==> config/ (alacritty, atuin, btop, gh, herdr, lazygit, gga, ssh, wezterm)"
  mkdir -p "$HOME/.config/alacritty" "$HOME/.config/atuin" "$HOME/.config/btop" \
           "$HOME/.config/gh" "$HOME/.config/herdr" "$HOME/.config/lazygit" \
           "$HOME/.config/gga" "$HOME/.ssh" "$HOME/.config/wezterm"
  install_example "$SRC/config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
  install_example "$SRC/config/atuin/config.toml" "$HOME/.config/atuin/config.toml"
  install_example "$SRC/config/btop/btop.conf" "$HOME/.config/btop/btop.conf"
  install_example "$SRC/config/gh/config.yml.example" "$HOME/.config/gh/config.yml"
  install_example "$SRC/config/gh/hosts.yml.example" "$HOME/.config/gh/hosts.yml"
  install_example "$SRC/config/herdr/config.toml" "$HOME/.config/herdr/config.toml"
  install_example "$SRC/config/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
  install_example "$SRC/config/gga/config" "$HOME/.config/gga/config"
  install_example "$SRC/config/gga/AGENTS.md" "$HOME/.config/gga/AGENTS.md"
  install_example "$SRC/config/ssh/config.example" "$HOME/.ssh/config"
  install_example "$SRC/config/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"

  echo ""
  echo "==> config/opencode/ (config, skills, prompts, commands, plugins)"
  mkdir -p "$HOME/.config/opencode"
  install_example "$SRC/config/opencode/opencode.json.example" "$HOME/.config/opencode/opencode.json"
  install_example "$SRC/config/opencode/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"
  install_example "$SRC/config/opencode/AGENTS.md" "$HOME/.config/opencode/AGENTS.md"
  install_example "$SRC/config/opencode/tui.json" "$HOME/.config/opencode/tui.json"
  install_example "$SRC/config/opencode/agent/ui-writer.md" "$HOME/.config/opencode/agent/ui-writer.md"
  install_tree "$SRC/config/opencode/skills" "$HOME/.config/opencode/skills"
  install_tree "$SRC/config/opencode/prompts" "$HOME/.config/opencode/prompts"
  install_tree "$SRC/config/opencode/commands" "$HOME/.config/opencode/commands"
  install_tree "$SRC/config/opencode/command" "$HOME/.config/opencode/command"
  install_tree "$SRC/config/opencode/plugins" "$HOME/.config/opencode/plugins"
  install_tree "$SRC/config/opencode/tui-plugins" "$HOME/.config/opencode/tui-plugins"

  echo ""
  echo "==> config/opencode/secrets/ (docs only — real keys stay local, NEVER committed)"
  mkdir -p "$HOME/.config/opencode/secrets"
  if [ ! -f "$HOME/.config/opencode/secrets/README.md" ]; then
    cp "$SRC/config/opencode/secrets/README.md" "$HOME/.config/opencode/secrets/README.md"
    echo "  created ~/.config/opencode/secrets/README.md"
  else
    echo "  skip ~/.config/opencode/secrets/README.md (already exists)"
  fi
  echo "  Fill YOUR_*_KEY files in ~/.config/opencode/secrets/ manually — see its README.md"

  echo ""
  echo "==> nvim/ (LazyVim — only if ~/.config/nvim is empty/missing)"
  if [ -f "$HOME/.config/nvim/init.lua" ]; then
    echo "  [!] ~/.config/nvim/init.lua exists — NOT overwriting your working nvim setup."
    echo "      Diff against $SRC/nvim/ manually if you want changes."
  elif [ -d "$HOME/.config/nvim" ] && [ -n "$(ls -A "$HOME/.config/nvim" 2>/dev/null)" ]; then
    echo "  [!] ~/.config/nvim is non-empty — NOT overwriting it. Copy manually:"
    echo "      cp -r $SRC/nvim/* ~/.config/nvim/"
  else
    install_tree "$SRC/nvim" "$HOME/.config/nvim"
  fi

  echo ""
  echo "==> gentle-stack/ (gentle-ai, pi, engram — templated, no secrets)"
  mkdir -p "$HOME/.gentle-ai" "$HOME/.pi/agent" "$HOME/.engram"
  install_example "$SRC/gentle-stack/gentle-ai/state.json.example" "$HOME/.gentle-ai/state.json"
  install_example "$SRC/gentle-stack/gentle-ai/pi-codegraph.json" "$HOME/.gentle-ai/pi-codegraph.json"
  install_example "$SRC/gentle-stack/pi/mcp.json.example" "$HOME/.pi/agent/mcp.json"
  install_example "$SRC/gentle-stack/pi/settings.json" "$HOME/.pi/agent/settings.json"
  install_example "$SRC/gentle-stack/engram/protocol-mode.json" "$HOME/.engram/protocol-mode.json"
}

# ---------------------------------------------------------------- ubuntu-server
install_ubuntu_server() {
  echo "==> Installing shell configs (cp .example -> real file)"
  install_example "$SRC/shell/.zshrc.example" "$HOME/.zshrc"
  install_example "$SRC/shell/.bashrc.example" "$HOME/.bashrc"
  install_example "$SRC/shell/.profile.example" "$HOME/.profile"
  install_example "$SRC/shell/.gitconfig.example" "$HOME/.gitconfig"
  [ -f "$SRC/shell/.zshenv.example" ] && install_example "$SRC/shell/.zshenv.example" "$HOME/.zshenv"
  [ -f "$SRC/shell/.p10k.zsh" ] && install_example "$SRC/shell/.p10k.zsh" "$HOME/.p10k.zsh"
  [ -f "$SRC/shell/.inputrc" ] && install_example "$SRC/shell/.inputrc" "$HOME/.inputrc"

  echo ""
  echo "==> tmux"
  install_example "$SRC/tmux/.tmux.conf" "$HOME/.tmux.conf"

  echo ""
  echo "==> config/ (btop, opencode, gh, ssh, atuin, himalaya)"
  mkdir -p "$HOME/.config/btop" "$HOME/.config/opencode" "$HOME/.config/gh" "$HOME/.ssh" "$HOME/.config/atuin" "$HOME/.config/himalaya"
  install_example "$SRC/config/btop/btop.conf" "$HOME/.config/btop/btop.conf"
  install_example "$SRC/config/opencode/opencode.json.example" "$HOME/.config/opencode/opencode.json"
  [ -f "$SRC/config/opencode/opencode.jsonc" ] && install_example "$SRC/config/opencode/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"
  install_example "$SRC/config/gh/config.yml.example" "$HOME/.config/gh/config.yml"
  install_example "$SRC/config/gh/hosts.yml.example" "$HOME/.config/gh/hosts.yml"
  install_example "$SRC/config/ssh/config.example" "$HOME/.ssh/config"
  install_example "$SRC/config/atuin/config.toml" "$HOME/.config/atuin/config.toml"
  install_example "$SRC/config/himalaya/config.toml.example" "$HOME/.config/himalaya/config.toml"
  [ -f "$SRC/config/fish/atuin.fish.example" ] && mkdir -p "$HOME/.config/fish/conf.d" && install_example "$SRC/config/fish/atuin.fish.example" "$HOME/.config/fish/conf.d/atuin.fish"

  echo ""
  echo "==> skills/ (hermes + opencode — docs only, no secrets)"
  if [ -d "$SRC/skills/hermes" ]; then
    mkdir -p "$HOME/.hermes/skills" "$HOME/.config/opencode/skills"
    echo "  hermes skills available in $SRC/skills/hermes/ (47) — copy manually if needed:"
    echo "    cp -r $SRC/skills/hermes/* ~/.hermes/skills/"
    echo "  opencode skills in $SRC/skills/opencode/ (23):"
    echo "    cp -r $SRC/skills/opencode/* ~/.config/opencode/skills/"
  fi
  if [ -d "$SRC/mcp" ] && [ -f "$SRC/mcp/opencode.json.example" ]; then
    echo "  MCP config template: $SRC/mcp/opencode.json.example -> ~/.config/opencode/opencode.json"
  fi

  echo ""
  echo "==> tools/ -> ~/.local/share/hermes/tools (executable, local disk only)"
  mkdir -p "$HOME/.local/share/hermes/tools"
  for t in hermes-vivaldi-bridge hermes-zen-bridge browser-ctl zen-ctl agentguard ha_control.sh websrc imgdl imgfx imggal imgpx imgqc opencode-run; do
    if [ -f "$SRC/tools/$t" ]; then
      cp "$SRC/tools/$t" "$HOME/.local/share/hermes/tools/$t"
      chmod +x "$HOME/.local/share/hermes/tools/$t"
      echo "  installed $t"
    fi
  done

  echo ""
  echo "==> infra templates (copy .env.example and fill secrets via AliasVault/sops)"
  if [ -d "$SRC/infra/env" ]; then
    echo "  Templates in $SRC/infra/env/*.example — copy to ~/sahacloud-infra/env/ and fill."
    echo "  Compose files already use \${VAR} — no hardcoded secrets."
  fi
}

if [ "$CHOICE" = "archlinux-krai" ]; then
  install_archlinux_krai
else
  install_ubuntu_server
fi

echo ""
echo "==> Done [$CHOICE]. Next steps:"
echo "  1. Fill YOUR_*_KEY placeholders in ~/.config/* (see archlinux-krai/docs/SECRETS.md)"
echo "  2. Store real secrets outside this repo — never commit them"
echo "  3. Run: exec zsh  (or source ~/.bashrc)"
echo "  Re-run with: ./install.sh $CHOICE"
