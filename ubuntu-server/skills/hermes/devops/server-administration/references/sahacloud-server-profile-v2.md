# SahaCloud Server Profile (v2 — July 17, 2026)

Quick reference for the SahaCloud server's hardware and resident services.

## Hardware

- **CPU:** Intel i5-4590 @ 3.30GHz (4C/4T, no HT)
- **RAM:** 6.1 GiB (tight for the workload)
- **Swap:** 3.1 GiB zram (`/dev/zram0`)
- **Disk root:** 69 GB (`/dev/sda2`) — baseline after cleanup: ~38 GB used, 28 GB free (58%)
- **Disk shared:** 120 GB VirtualBox shared folder (`SahaCloud`) — typically 89%+ full, check before cleanup
- **Platform:** VirtualBox VM (vboxadd-service exists but may fail — non-critical)

## OS

- Ubuntu 26.04 LTS (Resolute Raccoon)
- Kernel 7.0.0-28-generic PREEMPT_DYNAMIC

## Resident Heavy Processes (typical RAM+Swap at idle — excludes active TUI sessions)

| Process | Typical Total | Notes |
|---------|--------------|-------|
| Hermes Dashboard | ~870 MB | Port 9119 — heaviest resident process |
| OmniRoute | ~650 MB | LLM router, Docker container |
| VS Code Server (if connected) | ~730 MB | Auto-installs on Windows SSH connect. ~8 subprocesses. |
| Hermes Gateway | ~340 MB | WhatsApp/Telegram bridge |
| AliasVault API | ~130 MB | Docker container |
| WhatsApp Bridge | ~106 MB | Node.js process |
| Playwright MCP | ~103 MB | Port 8931 — used by Hermes `browser_*` tools |
| Neko Chromium | ~275 MB | Browser container, spread across 5 subprocesses |
| Hermes TUI node | ~103 MB | The TUI renderer process |
| SearXNG worker | ~85 MB | Docker container |
| Graphify | ~68 MB | Docker container |
| sahacloud-website | ~76 MB | Docker container (Next.js) |
| sahacloud-postgres (2 instances) | ~60 MB | Docker containers |

## Key Thresholds

- RAM available < 1 GB → swap pressure, performance degradation
- Swap > 80% → recommend killing idle heavy processes
- Disk shared > 85% → warn user, suggest cleanup
- Disk root > 80% → docker prune candidate

## Removed / Disabled Software (as of July 17, 2026)

- **liquid-lfm2.service** — llama.cpp LFM2.5-1.2B. Removed: service, binary, models (3.0 GB), config.yaml reference. No Hermes/OmniRoute dependency found.
- **ollama.service** — Ollama with moondream 1B. Removed: service, binary, models (1.7 GB). Not referenced by Hermes or OmniRoute.
- **code-manager/cartaya Astro preview** — Orphaned dev server. Killed (no systemd, won't survive reboot).
- **code-manager Next.js** — Orphaned dev server. Killed.
- **Docker build cache** — Periodically pruned via `docker builder prune --all --force`. Recovers ~1 GB typically.
- **Docker orphan images** — `docker image prune -a --force` recovers unused image layers.

## VS Code Server Handling

VS Code Remote SSH auto-installs `~/.vscode-server/` on every SSH connection from Windows. This consumes ~730 MB RAM across 8 processes and ~630 MB disk.

- **To block:** `touch ~/.vscode-server && chmod 000 ~/.vscode-server`
- **To unblock:** `rm ~/.vscode-server` (reinstalls on next connection)
- **WARNING:** Always ask user before blocking — if they want to keep using VS Code from Windows, blocking breaks their workflow. This happened in July 2026 session: blocked, user immediately wanted to reconnect, had to undo.