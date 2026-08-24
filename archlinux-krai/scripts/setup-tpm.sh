#!/usr/bin/env bash
# Clone TPM (tmux plugin manager) into ~/.tmux/plugins/tpm if missing.
# Idempotent — safe to re-run.
set -euo pipefail

TPM_DIR="$HOME/.tmux/plugins/tpm"
TPM_REPO="https://github.com/tmux-plugins/tpm"

if [ -d "$TPM_DIR" ]; then
  echo "  tpm already installed at $TPM_DIR — skip"
  exit 0
fi

mkdir -p "$HOME/.tmux/plugins"
git clone --depth 1 "$TPM_REPO" "$TPM_DIR"
echo "  tpm cloned to $TPM_DIR"
echo "  Inside a tmux session press: prefix (Ctrl+a) + I  to install plugins listed in .tmux.conf"
