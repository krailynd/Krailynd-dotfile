#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$REPO_DIR/ubuntu-server"

echo "==> Krailynd-dotfile bootstrap"
echo "    Source: $SRC"
echo ""

need_cmd() { command -v "$1" >/dev/null 2>&1 || echo "  [!] $1 not found — install it first"; }

echo "==> Prerequisites check"
need_cmd zsh
need_cmd tmux
need_cmd git
need_cmd docker
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
install_example "$SRC/config/gh/config.yml.example" "$HOME/.config/gh/config.yml"
install_example "$SRC/config/gh/hosts.yml.example" "$HOME/.config/gh/hosts.yml"
install_example "$SRC/config/ssh/config.example" "$HOME/.ssh/config"
install_example "$SRC/config/atuin/config.toml" "$HOME/.config/atuin/config.toml"
install_example "$SRC/config/himalaya/config.toml.example" "$HOME/.config/himalaya/config.toml"

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
echo "  Templates in $SRC/infra/env/*.example — copy to ~/sahacloud-infra/env/ and fill."
echo "  Compose files already use \${VAR} — no hardcoded secrets."

echo ""
echo "==> Done. Next steps:"
echo "  1. Fill YOUR_*_KEY placeholders in ~/.zshrc and ~/.config/*"
echo "  2. Store real secrets in AliasVault or sops — never commit them"
echo "  3. Run: exec zsh  (or source ~/.bashrc)"
