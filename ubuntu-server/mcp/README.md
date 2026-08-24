# MCPs

Model Context Protocol servers wired into OpenCode on the SahaCloud Ubuntu Server.

## What is MCP?

MCP (Model Context Protocol) lets an AI agent call external tools via a standard JSON-RPC interface. OpenCode loads them from `opencode.json` → `mcp` section. Each entry declares `type` (`local` = spawn command, `remote` = HTTP/SSE) and start command or URL.

## Servers in this repo

| Server | Type | Purpose | Required |
|---|---|---|---|
| `codegraph` | local `codegraph serve --mcp` | Codebase knowledge graph: symbols, call graph, impact analysis. Used by all SDD/review agents. | Optional but recommended |
| `engram` | local `engram mcp --tools=agent` | Persistent memory across sessions (decisions, bugfixes, patterns). | Optional |
| `context7` | remote `https://mcp.context7.com/mcp` | Up-to-date library docs (React, Next.js, etc.) | Optional, needs no token for basic use |

Only `codegraph` and `engram` are included in the sanitized example below. Add `context7` if you need live docs.

## Configure

Copy the example to your OpenCode config:

```bash
mkdir -p ~/.config/opencode
cp mcp/opencode.json.example ~/.config/opencode/opencode.json
# or merge into existing file: copy the `mcp` key only
```

Then restart OpenCode. Verify:

```bash
opencode mcp list
# or inside opencode: /mcp
```

## Files

- `opencode.json.example` — sanitized OpenCode config with `mcp.codegraph` + `mcp.engram` only, comments included. No tokens.
- `opencode.jsonc.example` — same in JSONC (allows `//` comments).

## Security

- No secrets are committed. Tokens (`GITHUB_TOKEN`, `NVAPI_KEY`, `OPENAI_API_KEY`) live in `~/.hermes/.env` or `env/*.env` on the server, never in `opencode.json`.
- Before committing, this repo is scanned: `grep -R "SECRET_PATTERN" mcp/` must return 0 hits.
- If you need authenticated MCPs, set env vars and reference them as `${ENV_VAR}` in `opencode.json` — don't hardcode.

## Troubleshooting

- `codegraph` not found → `cargo install codegraph` or `gentle-ai codegraph --help`.
- `engram` not found → `cargo install engram` and ensure `~/.local/bin` is on PATH.
- MCP timeout → check `opencode.json` `enabled: true` and command path is absolute for local servers.
