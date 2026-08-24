# SECURITY

## NEVER_SHARE

Never commit these — `.gitignore` already excludes them:

- `*.env`, `*.token`, `*creds*`, `*secret*`, `*.db`, `auth.json`, `hosts.yml`
- `cloudflared/*.json` (TunnelSecret), `credentials-summary.md`, `neko-creds.env`, `google_token.json`
- `whatsapp/`, `known_hosts`, `authorized_keys`, `*.log`, `.cache/`, `*.key`, `*.pem`, `secrets/`
- Any file containing `gho_*`, `nvapi-*`, `sk-*`, `ya29.`, `dfrt-`, `re_*`, `POSTGRES_PASSWORD`, `N8N_ENCRYPTION_KEY`, `BROWSERLESS_TOKEN`, `TunnelSecret`, bcrypt hashes

## Secret management

| Method | When |
|--------|------|
| **AliasVault** (`vault.sahacloud.dpdns.org`) | preferred — self-hosted password manager, zero-knowledge |
| **sops + age** | `sops --age age1... env/core.env` — encrypt env files in repo if needed |
| **Env vars** | export from `~/.hermes/.env` (chmod 600, gitignored) |

## Scanning

```bash
# before every commit
gitleaks detect --source . --verbose
# or
git secrets --scan
```

If a secret leaks: rotate immediately (`gh auth refresh`, regenerate API keys, `caddy hash-password` for Caddy), purge from git history (`git filter-repo` or BFG).

## Caddy hashes

```bash
caddy hash-password  # generates $2a$14$... — put result in Caddyfile as {$PREVIEW_HASH}
```

Never leave plaintext passwords in comments.
