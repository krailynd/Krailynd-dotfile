# SahaCloud Enabled Services Inventory (July 2026)

Discovered during dependency audit session. Use as baseline for future audits.

## System-level (`systemctl list-unit-files --state=enabled`)

### Infrastructure (DO NOT DISABLE)
- `docker.service` — Docker engine
- `containerd.service` — Container runtime
- `cloudflared.service` — Cloudflare Tunnel (all *.sahacloud.dpdns.org routing)
- `tailscaled.service` — Tailscale VPN (inter-device mesh)
- `ssh.service` / `sshd-keygen.service` — SSH server
- `fail2ban.service` — SSH brute-force protection
- `cron.service` — System cron

### Local AI / Inference (candidates for disable if unused)
- `liquid-lfm2.service` — llama.cpp serving LFM2.5-1.2B-Instruct (port 8555). Referenced in `~/.hermes/config.yaml` as provider `liquid-lfm2` but typically unused when OmniRoute is active. **611 MB swap zombie** when idle.
- `ollama.service` — Ollama server (port 11434). Has moondream model (1.7 GB disk). Not referenced in Hermes or OmniRoute config. ~35 MB RAM.

### MCP / Browser automation
- `playwright-mcp.service` — Playwright MCP server (port 8931). **USED BY HERMES** — referenced in config.yaml as `url: http://localhost:8931/mcp`. Powers `browser_*` tools. DO NOT DISABLE.

### Other
- `aionui-web.service` — AionUI WebUI (ports 7935, 25808). Not exposed via Caddy/Cloudflare. Not referenced by Hermes. Candidate for disable.
- `zramswap.service` — Compressed swap on zram0 (3.1 GB)
- `vboxadd-service.service` — VirtualBox guest additions (always fails on this VM but harmless)

## User-level (`systemctl --user list-unit-files --state=enabled`)

- `hermes-dashboard.service` — Hermes web dashboard (:9119). KEEP.
- `hermes-gateway.service` — Hermes gateway (WhatsApp, etc). KEEP.
- `graphify-viewer.service` — Graphify knowledge graph viewer. KEEP (graph.sahacloud.dpdns.org).
- `cloudflared-hermes.service` — Additional cloudflared for Hermes. KEEP.

## Orphaned processes (no systemd, started manually/by code-server)

These don't survive reboot but waste RAM while running:
- `npm exec next start -H 0.0.0.0 -p 3001` — Next.js from code-manager. Not routed by Caddy.
- `npm exec astro preview --host 0.0.0.0 --port 4321` — Astro from code-manager/cartaya. Not routed by Caddy.
- These were likely started by old code-server sessions.
