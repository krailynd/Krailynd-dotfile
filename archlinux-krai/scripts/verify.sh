#!/usr/bin/env bash
# Verify the archlinux-krai profile:
#  1. No real secrets (grep scan) in any shipped file.
#  2. Every *.example still contains at least one YOUR_* placeholder.
#  3. Report which required tools are missing on this machine.
set -euo pipefail

PROFILE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROFILE_DIR"

echo "==> [1/3] Secret scan (real tokens should never appear)"
BAD=0
HITS="$(grep -rnE 'sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{20,}|gho_[A-Za-z0-9]{20,}|hf_[A-Za-z0-9]{20,}|AKIA[A-Z0-9]{16}|ghu_[A-Za-z0-9]{20,}|ghs_[A-Za-z0-9]{20,}' . 2>/dev/null || true)"
if [ -n "$HITS" ]; then
  echo "[!] Possible leaked secrets:"
  echo "$HITS"
  BAD=1
else
  echo "    OK — no token-shaped strings found."
fi
# verify.sh and docs/ legitimately describe the rule — exclude them.
HOMES="$(grep -rn '/home/krailynd' . --exclude=verify.sh 2>/dev/null | grep -v '^\./docs/' || true)"
if [ -n "$HOMES" ]; then
  echo "[!] Absolute /home/krailynd paths leaked:"
  echo "$HOMES"
  BAD=1
else
  echo "    OK — no absolute /home/krailynd paths."
fi

echo "==> [2/3] Placeholder check (every .example must stay templated)"
# Structure-only templates (no secrets by design — documented in docs/SECRETS.md)
SAFE_EXAMPLES="
./config/gh/config.yml.example
./gentle-stack/pi/mcp.json.example
./gentle-stack/gentle-ai/state.json.example
"
for f in $(find . -name '*.example'); do
  case "$SAFE_EXAMPLES" in
    *"$f"*) continue ;;  # known structure-only, no placeholder required
  esac
  if ! grep -qE 'YOUR_[A-Z_]+' "$f"; then
    echo "[!] $f has no YOUR_* placeholder — it may contain a hardcoded value"
    BAD=1
  fi
done
echo "    Checked $(find . -name '*.example' | wc -l) .example files ($(echo "$SAFE_EXAMPLES" | grep -c '\.example$') structure-only)."

echo "==> [3/3] Tool availability (informational)"
for t in zsh tmux git nvim alacritty btop lazygit rg fzf bat lsd zoxide atuin carapace codegraph engram; do
  if command -v "$t" >/dev/null 2>&1; then
    echo "    ok   $t"
  else
    echo "    MISS $t"
  fi
done

echo ""
if [ "$BAD" -eq 0 ]; then
  echo "==> VERIFY PASSED — profile is clean."
else
  echo "==> VERIFY FAILED — fix the issues above." >&2
  exit 1
fi
