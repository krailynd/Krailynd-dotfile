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
  echo "  2) archlinux-krai — Arch Linux desktop (Hyprland/Waybar — coming soon)"
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

if [ "$CHOICE" = "archlinux-krai" ]; then
  if [ ! -d "$SRC/shell" ] && [ ! -d "$SRC/hypr" ] && [ ! -f "$SRC/README.md" ]; then
    echo "[!] archlinux-krai not populated yet — only placeholder README exists."
    echo "    Add configs to $SRC then re-run ./install.sh archlinux-krai"
    exit 0
  fi
  if [ "$(ls -A "$SRC" 2>/dev/null | wc -l)" -le 1 ] && [ -f "$SRC/README.md" ]; then
    echo "[!] archlinux-krai placeholder only — no configs to install yet."
    echo "    This profile is reserved for your Arch Linux upload."
    exit 0
  fi
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
fi
echo "    OK — missing tools shown above (optional)"
echo ""

install_example() {
  local src="$1" dst="$2"
  if [ -f "$dst" ]; then
    echo "  skip $dst (already exists)"
  elif [ -f "$src" ]; then
    cp "$src" "$dst"
    echo "  created $dst (from $(basename "$src"))"
  fi
}

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

echo ""
echo "==> Done [$CHOICE]. Next steps:"
echo "  1. Fill YOUR_*_KEY placeholders in ~/.zshrc and ~/.config/*"
echo "  2. Store real secrets in AliasVault or sops — never commit them"
echo "  3. Run: exec zsh  (or source ~/.bashrc)"
echo "  Re-run with: ./install.sh $CHOICE"
