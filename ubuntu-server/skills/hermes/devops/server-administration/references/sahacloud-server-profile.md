# SahaCloud Server Profile

Quick reference for the SahaCloud server's hardware and resident services.

## Hardware

- **CPU:** Intel i5-4590 @ 3.30GHz (4C/4T, no HT)
- **RAM:** 6.1 GiB (tight for the workload)
- **Swap:** 3.1 GiB zram (`/dev/zram0`)
- **Disk root:** 69 GB (`/dev/sda2`)
- **Disk shared:** 120 GB VirtualBox shared folder (`SahaCloud`)
- **Platform:** VirtualBox VM (vboxadd-service exists but may fail — non-critical)

## OS

- Ubuntu 26.04 LTS (Resolute Raccoon)
- Kernel 7.0.0-28-generic PREEMPT_DYNAMIC

## Resident Heavy Processes (typical RAM+Swap)

| Process | Typical Total | Notes |
|---------|--------------|-------|
| Hermes Dashboard | ~700 MB | Port 9119 |
| OmniRoute | ~630 MB | LLM router, port 20128 |
| OpenCode | ~680 MB | Only when active session |
| Hermes Gateway | ~340 MB | WhatsApp/Telegram bridge |
| llama-server (LFM2.5) | ~610 MB | Often 99% in swap when idle |
| VS Code Server | ~585 MB | **REMOVED Jul 2025** — blocked via file trick |

## Key Thresholds

- RAM available < 1 GB → swap pressure, performance degradation
- Swap > 80% → recommend killing idle heavy processes
- Disk shared > 85% → warn user, suggest cleanup
- Disk root > 80% → docker prune candidate

## Removed Software

- **VS Code Remote SSH server** (`~/.vscode-server`) — permanently blocked via `touch ~/.vscode-server && chmod 000`
