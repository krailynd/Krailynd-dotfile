---
name: notion-mcp
description: "Hermes MCP Integration for Notion (Krailynd Setup) — Full Notion management via MCP server with OAuth."
version: 1.0.0
author: Hermes (Krailynd)
license: MIT
platforms: [linux, macos, windows]
prerequisites: []
metadata:
 hermes:
 tags: [Notion, MCP, Productivity, Notes, Database, OAuth]
 homepage: https://mcp.notion.com
---

# Notion MCP Integration (Krailynd)

> **DEPRECATED (2026-07-08).** This OAuth path is unreliable for a headless/remote
> gateway: tokens expire in ~1h, the PKCE `code_verifier` is not persisted so
> refresh is impossible, and the `127.0.0.1` redirect can never reach a browser
> on a different machine (the Tailscale-remote case — see
> `references/2026-07-08-oauth-flow.md` for the full incident). The
> `mcp_servers.notion` entry in `~/.hermes/config.yaml` has been set to
> `enabled: false`. **Use the native `plugins/notion` tools instead**
> (`notion_search`, `notion_pages`, `notion_blocks`, `notion_databases`,
> `notion_comments`, `notion_users`, `notion_files`) — same integration-token
> auth model as the `skills/productivity/notion` skill, but as real registered
> tools instead of shell-out `curl`/`ntn` recipes. Do not re-run
> `hermes mcp login notion` or re-enable this MCP server without a good reason.

**Purpose:** Full Notion management via Hermes using the **official Notion MCP server** (`https://mcp.notion.com/mcp`). This is the **preferred method** for Krailynd, replacing AFFiNE and Outline for all note-taking and documentation.

## Why This Skill?
- Krailynd deprecated **AFFiNE** and **Outline** in favor of **Notion**.
- Hermes now uses **Notion MCP** for seamless integration (20+ tools: create, read, update, search, databases, etc.).
- **OAuth-based auth**: No manual token management; tokens auto-refresh.

---

## Do NOT use this skill — use the native plugin instead

**The MCP server is disabled (`enabled: false` in config.yaml).** The sections
below are retained only for historical context and in case the MCP server is
someday re-enabled (which, as of 2026-07-23, is still NOT recommended).

**For all Notion operations, use one of:**

1. **Native plugin tools** (available in Hermes sessions):
   `notion_search`, `notion_pages`, `notion_blocks`, `notion_databases`,
   `notion_comments`, `notion_files`. These use the same integration token
   (`NOTION_API_KEY` in `~/.hermes/.env`) but are real registered tools, not
   shell-out recipes.

2. **Direct API via `execute_code`** (for read-heavy or batch operations):
   Load the token from `~/.hermes/.env` via `dotenv`, call the Notion REST
   API with Python stdlib (`urllib.request`, `json`). This is the fastest and
   most reliable path for workspace audits, activity scans, and any operation
   that requires pagination or multi-step logic.

   ```python
   from dotenv import load_dotenv
   import os, json, urllib.request
   load_dotenv(os.path.expanduser("~/.hermes/.env"))
   TOKEN = os.environ["NOTION_API_KEY"]
   req = urllib.request.Request(
       "https://api.notion.com/v1/search",
       data=json.dumps({"query":"","page_size":100}).encode(),
       method="POST",
       headers={
           "Authorization": f"Bearer {TOKEN}",
           "Notion-Version": "2022-06-28",
           "Content-Type": "application/json",
       })
   with urllib.request.urlopen(req) as resp:
       data = json.loads(resp.read())
   ```

3. **`notion` skill** (`skill_view(name="notion")`) — documents `ntn` CLI and
   `curl` recipes for the same API.

4. **`notion-workspace-audit` skill** — for "what do I have", "what's new",
   "busca X en Notion" queries.

**Do NOT run `hermes chat -z "...Notion..."`** — it spawns a subagent that
cannot reliably access Notion tools and returns empty output.

---

## Historical setup (retained for reference only — do not follow)

### MCP Server Configuration
The Notion MCP server is pre-configured in `~/.hermes/config.yaml`:
```yaml
mcp_servers:
  notion:
    url: https://mcp.notion.com/mcp
    auth: oauth
    enabled: false  # <-- DISABLED
```

---

## Available Tools via MCP

| **Tool**               | **Description**                          | **Example Command**                          |
|------------------------|------------------------------------------|----------------------------------------------|
| `list_pages`           | List all pages in the workspace.         | "Busca todas mis páginas en Notion"         |
| `create_page`          | Create a new page.                       | "Crea una página llamada 'Roadmap Java'"     |
| `update_page`          | Edit page content/properties.            | "Añade un checklist a 'Roadmap Java'"       |
| `query_database`       | Query a Notion database.                 | "Muestra los primeros 10 registros de 'Creadores'" |
| `create_database`      | Create a new database.                   | "Crea una base de datos para proyectos"      |
| `archive_page`         | Archive (soft delete) a page.            | "Archiva la página 'Pruebas Notas'"         |

---

## Usage Examples

### Natural Language Commands (Any Hermes Session)
- **Create**: "Crea una página en Notion llamada 'Roadmap Java' en la carpeta 'Técnico'"
- **Search**: "Busca todas mis páginas en Notion y dime cuántas hay"
- **Edit**: "Añade un checklist en la página 'Roadmap Java' con los temas de Spring Boot"
- **Move**: "Mueve la página 'Pruebas Notas' a la carpeta 'Archivados'"
- **Database**: "Crea una base de datos para gestionar creadores de la agencia"

**These are handled by the native plugin tools** (notion_search, notion_pages, etc.)
or by execute_code with direct API calls — NOT by the disabled MCP server.
Do NOT use `hermes chat -z` — it returns empty output.

---

## Limitations
1. **No Permanent Deletion**: Notion's API only supports archiving (reversible from trash).
2. **Permissions**: Pages/databases must be **shared with the Hermes integration** in Notion:
   - Go to **Notion → Settings → Connections** → Select Hermes → Share required pages.

---

## Troubleshooting

### Token Expired/Invalid (`401 Unauthorized`)
- **Fix**: Re-run `hermes mcp login notion` and complete the OAuth flow again.
  **Note**: The `code_verifier` for PKCE is **not stored** in the system. If the token expires, you **must** restart the OAuth flow from scratch.

### Page/Database Not Found (`404`)
- **Fix**: Share the page/database with the Hermes integration in Notion:
 - Page Menu `...` → `Connect to` → Select Hermes.

### OAuth Flow Fails
- **Fix**: Ensure you copy the **full redirect URL** (including `code` and `state`) from the browser after authorization.
  **Critical**: The redirect to `127.0.0.1:PORT/callback` **will fail** (by design). Copy the URL from the browser's address bar and paste it back to Hermes to complete the flow.

### MCP Server Not Responding
- **Symptom**: `hermes mcp login notion` fails with `non-interactive environment and no cached tokens found`.
- **Fix**: Delete expired tokens and retry:
  ```bash
  rm -f ~/.hermes/mcp-tokens/notion.json
  hermes mcp login notion
  ```

---

## Pitfalls (Learned from Krailynd's Setup)
1. **Token Expiry**: The initial token from the first OAuth flow **expired** (`401 Unauthorized`). Always re-run `hermes mcp login notion` if API calls fail.
2. **Redirect URL**: The OAuth redirect to `127.0.0.1:PORT/callback` **fails by design**. Copy the full URL from the browser and paste it back to Hermes.
3. **MCP Server Not Listed**: If `hermes mcp list` does not show `notion`, ensure the MCP server is enabled in `~/.hermes/config.yaml`.
4. **No Manual Token Input**: Do **not** manually set `NOTION_API_KEY` in `.env`. The MCP server handles OAuth tokens internally.

### Direct API pitfalls (when using `execute_code` + REST API)
5. **PATCH not POST for appending blocks**: `POST /v1/blocks/{page_id}/children` returns HTTP 400 "Invalid request URL". The correct method is **`PATCH`** — this applies to all pages including those created inside databases.
6. **Database-page parent key**: When creating a page inside a database, use `"parent": {"database_id": ID}` (not `"page_id"`), and the title property must match the DB's title column name (often `"Name"`, not `"title"`). Using `"page_id"` for a database parent returns HTTP 400.
7. **No batch page creation**: Notion API does not support creating multiple pages in one call. Each page is a separate `POST /v1/pages`. For 50+ entries, add `time.sleep(0.35)` to avoid rate limits (3 req/sec).
8. **Annotations can cause 400**: `annotations` (bold/italic) inside `rich_text` can cause HTTP 400 if the structure is slightly off. When in doubt, omit them — plain `{"type":"text","text":{"content":"..."}}` always works.
9. **`rich_text` arrays with mixed annotations → use Python helpers**: When building `rich_text` arrays in `execute_code` that mix plain text and bold/italic segments, inline JSON is the #1 cause of Python `SyntaxError` (parenthesis/brace mismatch in heredocs). Always define `t()` and `t_bold()` helper functions and compose with those — never hand-type inline `{"type":"text","text":{"content":"..."},"annotations":{"bold":true}}` blocks.
10. **You can PATCH block content in-place**: `PATCH /v1/blocks/{block_id}` with a `{"paragraph": {"rich_text": [...]}}` body rewrites an existing block's content. This is essential for restructuring intro text without deleting and recreating blocks. Most guides only show appending.
11. **Select/multi_select values must match existing DB options exactly**: Sending `"Básico"` when the DB has `"Principiante"`, or `"Español"` when the DB has `"ES"`, returns HTTP 400 with no helpful message. Before any batch insert into a database, `GET /v1/databases/{id}` and read every `options` array for every select/multi_select property. Trying to `PATCH /v1/databases/{id}` to rewrite existing select options also fails with 400. To add a new option, create a single test page with the new value — Notion auto-creates it on success. See `references/batch-page-creation.md` → "Select/multi_select values must match existing options exactly" for the full pattern with duplicate detection.
12. **Callout emoji must be the unicode emoji character, not a name**: `"icon": {"type": "emoji", "emoji": "objective"}` returns HTTP 400. Use the actual emoji character (`"🎯"`) or the unicode escape (`"\U0001F3AF"`) in Python source. See `references/block-building-batch-ops.md` → "Pitfall 1".

For full reproducible patterns (create page → add blocks → create embedded DB → populate), see `references/batch-page-creation.md`.

For restructuring complex Notion pages containing multiple inline databases (read structure → query child DBs → batch PATCH properties → rewrite intro blocks in-place), see `references/restructuring-complex-pages.md`. Covers roadmap audits, phase reordering, and any "analyze and improve my Notion page" request.

For building pages with 50-100+ rich blocks (headings, callouts with annotations, bulleted/numbered lists, batch block appending), see `references/block-building-batch-ops.md`. Covers helper functions for rich text, emoji pitfalls, Python syntax hazards in block dicts, and batch size limits.

---

## Analyzing screenshots of Notion pages (vision fallback)

When the user attaches a screenshot of their Notion workspace and asks for
analysis, `vision_analyze` may fail if the active vision provider's API key is
misconfigured (e.g., `OPENAI_API_KEY` pointing to a `YOUR_NVAPI_KEY` NVIDIA key).
The workaround that works: call the **NVIDIA NIM endpoint directly** via
`execute_code` with `NVIDIA_API_KEY` (the correct key) and a vision-capable
model like `meta/llama-4-maverick-17b-128e-instruct`.

Steps:
1. Read the image file from `~/.hermes/images/upload_*` and base64-encode it.
2. POST to `https://integrate.api.nvidia.com/v1/chat/completions` with the
   `NVIDIA_API_KEY` env var (not `OPENAI_API_KEY`), model
   `meta/llama-4-maverick-17b-128e-instruct`, and an open-ended prompt asking
   to transcribe all visible text and describe the structure/properties.
3. Use the transcript to identify the page/database by title.
4. Search Notion via the API direct path (`POST /v1/search` with the query)
   to find the actual page ID.
5. Read the full page content (`GET /v1/blocks/{id}/children`) and properties
   (`GET /v1/pages/{id}`) — the screenshot is only a partial view; the API
   gives the complete picture including child databases and all properties.

Payload format is the same OpenAI-compatible chat completions schema with
`image_url` content parts using `data:image/png;base64,...` URIs.

This same pattern works for any image the user attaches to the chat —
screenshots of docs, diagrams, UI mockups, etc. — when `vision_analyze` fails.

## References
- [Notion API Documentation](https://developers.notion.com)
- [Notion MCP Server](https://mcp.notion.com/mcp)
- [Hermes MCP Documentation](https://hermes-agent.nousresearch.com/docs#mcp)
- `references/batch-page-creation.md` — PATCH vs POST, database-page parents, batch operations, select/multi_select option matching, duplicate detection pattern