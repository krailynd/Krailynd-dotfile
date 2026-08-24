---
name: engram
description: "Use for Engram memory: save, search, cloud sync, agents."
---

# /engram — Engram Memory System (Gentleman-Programming)

Engram is a **single Go binary** with SQLite + FTS5 that gives AI coding agents persistent memory across sessions. Works with any MCP-compatible agent (Claude Code, OpenCode, Gemini CLI, Codex, VS Code, Cursor, Windsurf, etc.).

**Binary location:** `/home/sahacloud/.local/bin/engram`
**Data directory:** `~/.engram/engram.db` (override with `ENGRAM_DATA_DIR`)

---

## Quick Commands

| Task | Command |
|------|---------|
| Save a memory | `engram save "Title" "What/Why/Where/Learned content" --type architecture` |
| Search memories | `engram search "query" --match-mode any` |
| Search broader (any token) | `engram search "auth session" --match-mode any` |
| Get context for new session | `engram context` |
| View recent timeline | `engram timeline <obs_id>` |
| Show stats | `engram stats` |
| Launch TUI | `engram tui` |
| Start HTTP API (port 7437) | `engram serve` |
| Start MCP server (stdio) | `engram mcp` |
| Git sync export | `engram sync` |
| Git sync import | `engram sync --import` |
| Cloud enroll | `engram cloud enroll <project>` |
| Cloud sync | `engram sync --cloud --project <project>` |
| Cloud status | `engram cloud status` |
| Conflicts list | `engram conflicts list --project <project>` |
| Conflicts scan (semantic) | `engram conflicts scan --project <project> --semantic --apply --max-semantic 5 --yes` |

---

## Memory Types (use with `--type`)

| Type | When to use |
|------|-------------|
| `architecture` | Architectural decisions, patterns, tradeoffs |
| `decision` | Technical choices with rationale |
| `bugfix` | What was wrong, why, how fixed |
| `pattern` | Reusable code patterns, conventions |
| `config` | Environment setup, configuration changes |
| `discovery` | Important findings, gotchas |
| `learning` | Concepts learned, mental models |
| `manual` | Default fallback |

---

## Memory Content Format (required for `engram save`)

```
**What**: [concise description of what was done]
**Why**: [the reasoning, user request, or problem that drove it]
**Where**: [files/paths affected, e.g. src/auth/middleware.ts]
**Learned**: [any gotchas, edge cases, or decisions made — omit if none]
```

Example:
```bash
engram save "JWT auth middleware" \
  "**What**: Replaced express-session with jsonwebtoken for auth
**Why**: Session storage doesn't scale across multiple instances
**Where**: src/middleware/auth.ts, src/routes/login.ts
**Learned**: Must set httpOnly and secure flags on the cookie, refresh tokens need separate rotation logic" \
  --type architecture
```

---

## MCP Tools (20 tools available via `engram mcp`)

| Category | Tools |
|----------|-------|
| Save & Update | `mem_save`, `mem_update`, `mem_delete`, `mem_suggest_topic_key` |
| Search & Retrieve | `mem_search`, `mem_context`, `mem_timeline`, `mem_get_observation` |
| Session Lifecycle | `mem_session_start`, `mem_session_end`, `mem_session_summary` |
| Conflict Surfacing | `mem_judge`, `mem_compare` |
| Lifecycle Review | `mem_review` |
| Utilities | `mem_save_prompt`, `mem_stats`, `mem_capture_passive`, `mem_merge_projects`, `mem_current_project`, `mem_doctor` |

**Key: `mem_search` match_mode**
- `"all"` (default): every query token must match (AND)
- `"any"`: broader recall — any token can match (OR)

---

## Agent Setup (one-liners)

| Agent | Command |
|-------|---------|
| Claude Code | `claude plugin marketplace add Gentleman-Programming/engram && claude plugin install engram` |
| OpenCode | `engram setup opencode` |
| Gemini CLI | `engram setup gemini-cli` |
| Codex | `engram setup codex` |
| VS Code (Copilot) | `engram setup vscode-copilot` |
| Cursor | `engram setup cursor` |
| Windsurf | `engram setup windsurf` |
| Pi | `engram setup pi` |

After setup, **restart your agent**. It launches `engram mcp` automatically via stdio — no manual server needed.

---

## Cloud Integration (Opt-In)

Local SQLite stays authoritative. Cloud is replication/shared access only.

```bash
# Local smoke test
docker compose -f docker-compose.cloud.yml up -d
engram cloud config --server http://127.0.0.1:18080
engram cloud enroll smoke-project
engram sync --cloud --project smoke-project
```

**Important env vars:**
- `ENGRAM_CLOUD_SERVER` — cloud server URL
- `ENGRAM_CLOUD_TOKEN` — auth token
- `ENGRAM_CLOUD_ALLOWED_PROJECTS` — comma-separated allowlist (use `*` for all)
- `ENGRAM_CLOUD_AUTOSYNC=1` — enable background autosync (needs token + server)

---

## Git Sync (Cross-Machine)

```bash
engram sync                    # Export new memories as compressed chunk
git add .engram/ && git commit -m "sync engram memories"
engram sync --import           # On another machine: import new chunks
engram sync --status           # Check sync status
```

---

## Conflict Detection & Semantic Judging

Engram surfaces memory conflicts on save (FTS5 lexical) and can use an LLM to judge semantic similarity.

```bash
# List conflicts
engram conflicts list --project my-project

# Scan with semantic LLM judging (uses your agent's CLI — $0 on Pro/Max/Plus)
export ENGRAM_AGENT_CLI=claude   # or opencode
engram conflicts scan --project my-project --semantic --apply --max-semantic 5 --yes
```

---

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ENGRAM_DATA_DIR` | Override data directory | `~/.engram` |
| `ENGRAM_PORT` | HTTP server port | `7437` |
| `ENGRAM_URL` | Point Pi plugin at existing `engram serve` | `http://127.0.0.1:7437` |
| `ENGRAM_HTTP_TOKEN` | Bearer auth for HTTP server (destructive/export routes) | unset (open) |
| `ENGRAM_TIMEZONE` | TUI/cloud dashboard timezone | system local |
| `ENGRAM_CLOUD_SERVER` | Cloud server URL | unset |
| `ENGRAM_CLOUD_TOKEN` | Cloud auth token | unset |
| `ENGRAM_CLOUD_ALLOWED_PROJECTS` | Project allowlist for cloud serve | unset |
| `ENGRAM_CLOUD_TOKEN_PEPPER` | Secret for managed token hashing | unset |
| `ENGRAM_AGENT_CLI` | Agent CLI for semantic judging (`claude`, `opencode`) | unset |

---

## When to Use This Skill

- User wants to save/retrieve persistent memories across sessions
- Setting up Engram for a new agent (Claude Code, OpenCode, etc.)
- Configuring cloud sync or git sync
- Debugging memory conflicts
- Need to query existing Engram database from Hermes

---

## Integration with Graphify (Code Knowledge Graph)

Engram (persistent memory) + Graphify (code knowledge graph) = complete long-term context.

| Engram | Graphify |
|--------|----------|
| Decisions, bugs, patterns, conventions (semantic) | Code structure, imports, calls, architecture (structural) |
| Accumulates across sessions | Rebuildable from source |
| SQLite + FTS5 | NetworkX + community detection |
| 20 MCP tools | MCP server + CLI query/path/explain |

### Combined Workflow

1. **Graphify** a repo → architectural map with communities, god nodes, surprises
2. **Save key insights to Engram**:
   ```bash
   engram save "Auth: JWT middleware pattern" \
     "**What**: JWT replaces sessions for stateless auth\n**Why**: Scales across instances\n**Where**: src/auth/middleware.ts (graphify community 3)\n**Learned**: httpOnly + secure flags required, refresh token rotation" \
     --type pattern
   ```
3. **Next session**: `engram context` recalls decisions; `graphify query "auth flow"` traces code paths

### MCP Integration (Both as MCP Servers)

```bash
# Terminal 1: Graphify MCP
graphify /path/to/repo --mcp

# Terminal 2: Engram MCP
engram mcp
```

Hermes can connect to both and use tools from each simultaneously.

### Suggested Engram Types for Graphify Insights

- `architecture` — god nodes, community structure, cross-cutting concerns
- `pattern` — recurring code patterns (factory, strategy, middleware chains)
- `discovery` — surprising connections, bridge nodes, hidden dependencies
- `decision` — architectural choices implied by the graph

### Shared Obsidian Vault

Both export to Obsidian:
- `graphify export obsidian --dir ~/vaults/project`
- `engram obsidian-export ~/vaults/project`

Point both at the same vault for unified knowledge base.