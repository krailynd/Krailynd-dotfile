# SahaCloud Enabled Services Inventory (v2 — July 17, 2026)

Discovered during server cleanup and dependency audit sessions. Use as baseline for future audits.

## System-level (`systemctl list-unit-files --state=enabled`)

### Infrastructure (DO NOT DISABLE)
- `docker.service` — Docker engine
- `containerd.service` — Container runtime
- `cloudflared.service` — Cloudflare Tunnel (all *.sahacloud.dpdns.org routing)
- `tailscaled.service` — Tailscale VPN (inter-device mesh)
- `ssh.service` / `sshd-keygen.service` — SSH server
- `fail2ban.service` — SSH brute-force protection
- `cron.service` — System cron

### MCP / Browser automation
- `playwright-mcp.service` — Playwright MCP server (port 8931). **USED BY HERMES** — referenced in config.yaml as `url: http://localhost:8931/mcp`. Powers `browser_*` tools. DO NOT DISABLE.

### Other non-standard services
- `aionui-web.service` — AionUI WebUI (ports 7935, 25808). Not exposed via Caddy/Cloudflare. Not referenced by Hermes. Candidate for disable if unused.
- `zramswap.service` — Compressed swap on zram0 (3.1 GB)
- `vboxadd-service.service` — VirtualBox guest additions (always fails on this VM but harmless)

## User-level (`systemctl --user list-unit-files --state=enabled`)

- `hermes-dashboard.service` — Hermes web dashboard (:9119). KEEP.
- `hermes-gateway.service` — Hermes gateway (WhatsApp, etc). KEEP.
- `graphify-viewer.service` — Graphify knowledge graph viewer. KEEP (graph.sahacloud.dpdns.org).
- `cloudflared-hermes.service` — Additional cloudflared for Hermes. KEEP.

## REMOVED Services (do NOT re-enable unless user explicitly requests)

| Service | Removed | Disk freed | RAM freed | Reason |
|---------|---------|------------|-----------|--------|
| `liquid-lfm2.service` | Jul 17 2026 | 3.0 GB | ~611 MB | llama.cpp LFM2.5-1.2B — not used by Hermes/OmniRoute. Config reference also purged from config.yaml |
| `ollama.service` | Jul 17 2026 | 1.7 GB | ~35 MB | Ollama + moondream model — not referenced by Hermes, OmniRoute, or vision |
| code-manager Astro (cartaya) | Jul 17 2026 | 168 MB disk | ~138 MB | Orphaned from old code-server. No Caddy/Cloudflare route |
| code-manager Next.js | Jul 17 2026 | none | ~129 MB | Orphaned from old code-server. No Caddy/Cloudflare route |

## Docker Images Present (July 17, 2026)

16 images total, 13 active. ~8.6 GB on disk, 94% reclaimable (shared layers). Periodically prune with:
- `docker builder prune --all --force` (recovered 1.09 GB Jul 17)
- `docker image prune -a --force` (recovered 7.4 MB Jul 17)

## TUI Workers Cleanup

Old TUI sessions can leave `slash_worker` processes alive consuming RAM+Swap:
```bash
# List active workers with session keys
ps aux | grep '[s]lash_worker' | while read -r line; do
  pid=$(echo "$line" | awk '{print $2}')
  session=$(echo "$line" | grep -oP 'session-key \K\S+')
  start=$(ps -p "$pid" -o lstart= 2>/dev/null)
  rss=$(awk '/VmRSS/{printf "%.0f", $2/1024}' /proc/$pid/status 2>/dev/null)
  swap=$(awk '/VmSwap/{printf "%.0f", $2/1024}' /proc/$pid/status 2>/dev/null)
  echo "PID:$pid  RSS:${rss}MB  SWAP:${swap}MB  START:$start  SESSION:$session"
done
```
Compare session keys with current `$HERMES_SESSION_KEY` — kill any worker whose session doesn't match the active session. Each old worker wastes ~80 MB combined RAM+Swap.