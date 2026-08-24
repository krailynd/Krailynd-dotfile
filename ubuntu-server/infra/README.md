# infra

Docker Compose stacks + Caddy + helper scripts — sanitized templates.

## Layout

```
infra/
├── caddy/Caddyfile.example   # copy to ~/sahacloud-infra/caddy/Caddyfile, fill {$PREVIEW_HASH}
├── env/*.env.example         # copy to ~/sahacloud-infra/env/*.env, fill REPLACE_WITH_*
├── stacks/*/docker-compose.yml  # direct copy, already uses ${VAR}
└── scripts/*.sh              # health, update, preview
```

## Stacks

| Stack | Port / Route |
|-------|--------------|
| `core` | Caddy `127.0.0.1:8080`, Postgres 17, Redis — shared `sahacloud-net` |
| `aliasvault` | vault.sahacloud.dpdns.org (self-hosted password manager) |
| `homeassistant` | homeassistant.sahacloud.dpdns.org |
| `n8n` | `127.0.0.1:5678` + browserless `127.0.0.1:3055` |
| `nextcloud` | placeholder (template) |
| `mattermost` | placeholder (template) |
| `outline` | placeholder (template) |
| `penpot` | placeholder (template) |
| `excalidraw` | placeholder (template) |
| `website` | sahacloud.dpdns.org |

Only Postgres/Redis use `core-internal` (no external exposure). TLS via Cloudflare Tunnel (`cloudflared` systemd), Caddy is HTTP-only.

## Env files

All real values are `REPLACE_WITH_*` placeholders. Fill from AliasVault or `sops`:

```bash
cp infra/env/core.env.example ~/sahacloud-infra/env/core.env
nano ~/sahacloud-infra/env/core.env   # 600 perms
```

## Scripts

```bash
bash ~/sahacloud-infra/scripts/health.sh   # check all services
bash ~/sahacloud-infra/scripts/update.sh   # backup -> pull -> restart
bash ~/sahacloud-infra/scripts/start-preview.sh <proyecto>  # port 4400 only
bash ~/sahacloud-infra/scripts/stop-preview.sh 4400
```

Preview is hard-locked to 4400 (Caddy + tunnel route only that port).
