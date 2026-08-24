---
name: github
description: "Unified GitHub integration for @krailynd and @sahahacking organization: search repos, create PRs, manage issues, releases, and CI/CD via gh CLI."
version: 1.0.0
author: sahacloud
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [GitHub, Repos, PR, Issues, Organization, sahahacking, krailynd, Automation]
prerequisites:
  commands: [gh, git]
---

# /github — GitHub Integration for SahaCloud

Unified GitHub workflow skill tailored for user **`krailynd`** (YOUR_NAME) and organization **`sahahacking`**.

---

## 1. Environment & Account Identity

- **Active User**: `krailynd`
- **Organization**: `sahahacking` (`https://github.com/sahahacking`)
- **CLI Authentication**: Native `gh` CLI via HTTPS credential helper (`/usr/bin/gh`)
- **Environment Token**: `GITHUB_TOKEN` set in `~/.hermes/.env`

---

## 2. Quick Command Reference (`gh` CLI First)

### Account & Organization Lookup
```bash
# Check auth status & rate limits
gh auth status

# List personal repos (krailynd)
gh repo list krailynd --limit 20

# List organization repos (sahahacking)
gh repo list sahahacking --limit 20
```

### Repo Management
```bash
# Create personal repository
gh repo create krailynd/NUEVO_REPO --public --clone

# Create organization repository
gh repo create sahahacking/NUEVO_REPO --private --clone

# View repository details
gh repo view OWNER/REPO
```

### Pull Requests
```bash
# Create PR targeting main branch
gh pr create --title "feat: DESCRIPCION" --body "DETALLES" --web=false

# List open PRs
gh pr list

# Merge PR
gh pr merge PR_NUMBER --squash --delete-branch
```

### Issues & Triage
```bash
# Create issue
gh issue create --title "bug: DESCRIPCION" --body "PASOS"

# List open issues
gh issue list
```

---

## 3. Organizational Context (`sahahacking`)

When working inside a project under `/home/sahacloud/SahaCloud/projects/` or `/home/sahacloud/sahahacking/`:
- Always target the `sahahacking` org when creating or pushing corporate tools (e.g. `sahahacking/open-sahadisk`).
- Personal experimental/portfolio projects target `krailynd` (e.g. `krailynd/maison-tienda-moda`).

---

## 4. Conventional Commit Standards

When staging and pushing via Hermes:
- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation updates
- `refactor:` for code restructures
- `infra:` for server/Docker/Caddy changes

**Rule**: NEVER add "Co-Authored-By" or AI attribution to commit messages. Use clean Conventional Commits only.
