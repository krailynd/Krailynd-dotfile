# tools

Helper scripts — all live on local disk (`~/.local/share/hermes/tools/`) because `~/SahaCloud/` is a vboxsf mount (no exec bit).

| Tool | Purpose |
|------|---------|
| `hermes-vivaldi-bridge` | HTTP bridge: Hermes ↔ Vivaldi browser (CDP). Token auth via `~/.hermes/vivaldi-bridge.token` |
| `hermes-zen-bridge` | HTTP bridge: Hermes ↔ Zen browser (CDP + extension) |
| `browser-ctl` | CLI to drive Vivaldi/Zen via bridge (open, screenshot, evaluate JS) |
| `zen-ctl` | Zen-specific control wrapper |
| `agentguard` | Pre-exec guard: blocks dangerous commands before agent runs them |
| `ha_control.sh` | Home Assistant REST helper (uses `HA_TOKEN` env, never hardcoded) |
| `websrc` | Extract/ scrape web page to markdown (trafilatura + readability) |
| `imgdl` | Download image from URL to `~/.hermes/images/` |
| `imgfx` | Image effects (resize, blur, etc.) via Python PIL |
| `imggal` | Build HTML gallery from images |
| `imgpx` | Pixelate / redact regions of an image |
| `imgqc` | Quick-check image existence / metadata |
| `opencode-run` | Wrapper: run opencode from any project dir with correct context |

## Install

```bash
cp ubuntu-server/tools/* ~/.local/share/hermes/tools/
chmod +x ~/.local/share/hermes/tools/*
```

## Security

- Bridges use token files (`*.token`, chmod 600) — never commit tokens.
- `ha_control.sh` reads `HA_TOKEN` from env / `~/.hermes/.env` (gitignored).
- `agentguard` has no secrets — it only filters command strings.
