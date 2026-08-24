#!/usr/bin/env bash
# Arch Linux bootstrap — installs the tools this dotfile profile expects.
# Run as root or via sudo. Safe to re-run (idempotent).
set -euo pipefail

# ---- Base system packages (official repos) ----
PACMAN_PKGS=(
  zsh            # default shell (oh-my-zsh optional)
  tmux           # terminal multiplexer (TPM config in this profile)
  git            # version control
  neovim         # editor (LazyVim config in nvim/)
  alacritty      # terminal emulator
  btop           # system monitor
  ripgrep        # fast grep (fzf previews, telescope)
  fzf            # fuzzy finder
  bat            # pretty cat
  lsd            # modern ls
  zoxide         # smart cd
  atuin          # shell history sync/search
  carapace       # shell completions (used by .zshrc)
  wl-clipboard   # wl-copy used by extractPorts() in .zshrc
  ttf-jetbrains-mono-nerd  # terminal font for Alacritty/tmux glyphs
)

echo "==> [1/4] Installing official packages (pacman)"
if ! command -v pacman >/dev/null 2>&1; then
  echo "[!] pacman not found — this script targets Arch Linux. Aborting." >&2
  exit 1
fi
sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"

# ---- AUR / external tools (need yay or paru) ----
# These are NOT in official repos; install manually or via an AUR helper.
#   powerlevel10k:  yay -S --noconfirm powerlevel10k
#                   (or: git clone https://github.com/romkatv/powerlevel10k ~/.powerlevel10k)
#   lazygit:        yay -S --noconfirm lazygit
#   tpm (tmux plugin manager) is cloned by scripts/setup-tpm.sh (no AUR needed)
#   oh-my-zsh:      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
if ! command -v yay >/dev/null 2>&1 && ! command -v paru >/dev/null 2>&1; then
  echo "[i] No AUR helper found. Install one to get: powerlevel10k, lazygit"
  echo "    https://github.com/Jguer/yay#readme  or  https://github.com/Morganamilo/paru"
fi

# ---- TPM (tmux plugin manager) ----
echo "==> [2/4] Ensuring tmux TPM is installed"
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
  echo "  tpm already present — skip"
fi

# ---- LazyVim ----
echo "==> [3/4] Preparing LazyVim (nvim/)"
echo "  The repo ships a full nvim/ tree. Install it with:"
echo "    ./install.sh archlinux-krai"
echo "  (it copies nvim/ to ~/.config/nvim only when the destination is empty)"
echo "  Manual alternative: https://www.lazyvim.org/installation"

# ---- Run the profile installer ----
echo "==> [4/4] Running the dotfile installer"
REPO_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
if [ -x "$REPO_DIR/install.sh" ]; then
  "$REPO_DIR/install.sh" archlinux-krai
else
  echo "  install.sh not found at $REPO_DIR/install.sh — run it manually."
fi

echo ""
echo "==> Done. Final steps:"
echo "  1. chsh -s /usr/bin/zsh   (make zsh your login shell)"
echo "  2. exec zsh && p10k configure   (first-time prompt theme)"
echo "  3. Fill YOUR_*_KEY placeholders in ~/.config/* and ~/.config/opencode/secrets/"
echo "  4. tmux: prefix+I  inside a tmux session to install TPM plugins"
