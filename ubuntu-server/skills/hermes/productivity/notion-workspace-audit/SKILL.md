---
name: notion-workspace-audit
description: "Full inventory and structure mapping of a Notion workspace — find every page, database, and their hierarchy."
version: 1.0.0
author: hermes
---

# Notion Workspace Audit

Use when the user asks "what do I have in Notion?", "audit my workspace", "check everything",
"revisa mi notion", "dónde está cada cosa", or "qué notas/páginas/DBs tengo".

## Trigger phrases
- "qué tengo en notion"
- "revisa mi notion"
- "audita mi workspace"
- "dónde está [X] en notion"
- "mapea mi notion"
- "qué databases tengo"
- "qué páginas tengo"
- "busca en mis notas de notion si hay algo sobre [tema]"
- "¿tengo algo de [X] en notion?"
- "cuáles son los mejores [X] en notion", "rank [X] por calidad/futuro/prioridad"

## Recent activity audit ("what's new in my Notion")

When the user asks "qué hay de nuevo en mi Notion", "qué se creó hoy",
"qué cambió recientemente" — sort the full workspace by `created_time` desc,
filter for today's date, and separate consolidated pages (Radar) from
individual source entries. See `references/recent-activity-audit.md` for the
full reproducible script and the key discovery that **Radar pages store all
content in page properties (rich_text), not in child blocks**.

### Key findings for recent-activity audits
- `POST /v1/search` with `query: ""` + pagination gives every item with
  `created_time` and `last_edited_time` — sort/filter client-side.
- Radar pages (from the n8n content engine) have **0 child blocks**. Their
  content (Resumen, Mini Guion Skeleton, Hook, Nicho, Fuentes) lives in
  page properties: `GET /v1/pages/{id}` → iterate
  `properties.*.rich_text[].plain_text`.
- Companion "— Guion Maestro" pages DO have child blocks with the full
  structured script — use `/blocks/{id}/children` for those.
- The audit can be done entirely from `execute_code` with Python stdlib
  (`urllib.request`, `json`, `dotenv`) — faster and more reliable than
  `hermes chat -z` or the deprecated MCP server.

## Topic search across all pages

When the user asks "¿tengo notas sobre X?" or "busca [tema] en Notion":

### Step 1 — Fetch ALL pages with pagination (not a query search)

Do NOT rely on `query` parameter alone — Notion returns false positives (e.g. searching
"formula 1" or "f1" returns pages that merely contain "1" in body content, not title matches).

Fetch the full page list with empty query, then filter titles client-side:

```bash
source ~/.hermes/.env

python3 - <<'EOF'
import subprocess, json, sys

KEYWORDS = ["formula 1", "f1", "fórmula 1"]  # adapt per request — lowercase
API_KEY = subprocess.check_output("grep NOTION_API_KEY ~/.hermes/.env | cut -d= -f2", shell=True).decode().strip()

headers = [
    "-H", f"Authorization: Bearer {API_KEY}",
    "-H", "Content-Type: application/json",
    "-H", "Notion-Version: 2022-06-28"
]

results = []
cursor = None
while True:
    body = {"query": "", "page_size": 100}
    if cursor:
        body["start_cursor"] = cursor
    raw = subprocess.check_output(
        ["curl", "-s", "-X", "POST", "https://api.notion.com/v1/search"] + headers +
        ["-d", json.dumps(body)]
    )
    data = json.loads(raw)
    results.extend(data.get("results", []))
    if not data.get("has_more"):
        break
    cursor = data.get("next_cursor")

print(f"Total pages scanned: {len(results)}")
hits = []
for r in results:
    obj = r.get("object", "")
    title = ""
    if obj == "page":
        for v in r.get("properties", {}).values():
            if v.get("type") == "title":
                title = "".join(t.get("plain_text", "") for t in v.get("title", []))
                break
    elif obj == "database":
        title = "".join(t.get("plain_text", "") for t in r.get("title", []))
    if any(kw in title.lower() for kw in KEYWORDS):
        hits.append(f"  [{obj}] {title} — {r['id']}")

if hits:
    print(f"\nMatches ({len(hits)}):")
    for h in hits: print(h)
else:
    print("\nNo matches found in any page/database title.")
EOF
```

### Step 2 — Search with topic-variant queries too

After title scan, also search with broader variant keywords (team names, people, related terms)
to catch tangentially related pages. Filter each result set client-side by title.

### Key pitfalls for topic search

- **False positives from query param**: `"query": "f1"` matches any page mentioning "1" internally.
  Always filter the returned titles yourself — don't trust Notion's relevance ranking for topic search.
- **Pagination is mandatory**: workspace can exceed 100 items (`has_more: true`). Always loop
  until `has_more` is false. A single 100-item call is not a complete search.
- **Title-only search is fast but incomplete**: if nothing found in titles, tell the user the
  search only covers page/DB titles — body content requires fetching each page's blocks separately,
  which is expensive. Offer to do a deeper scan only if user confirms. When the user asks you to
  read and compare/rank the *full content* of pages (not just titles), see
  `references/extracting-page-content.md` for the recursive block-extraction pattern
  (handles `has_children`, `column_list`/`column` nesting, and bulk DB→content reads).
- **Shared-pages limitation**: only pages/DBs shared with the Hermes integration appear.
  If the user says "I know I have a note on X", check if the page is connected to the integration.

---

## Three-phase approach

### Phase 1: Full inventory via POST search (mandatory first step)

```bash
curl -s -X POST "https://api.notion.com/v1/search" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{"page_size": 100}'
```

Returns ALL pages + data_sources the integration can see. Parse into object type, title,
parent type, parent ID, and own ID. Build a `parent -> [children]` map.

### Phase 2: Read root pages as Markdown to reveal hierarchy

```bash
curl -s "https://api.notion.com/v1/pages/{root_page_id}/markdown" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2025-09-03"
```

The markdown endpoint exposes inline databases (`<database url="..." inline="true" data-source-url="collection://...">`),
child pages (`<page url="...">`), callouts, columns — all in ONE call. Follow each `<page>` and `<database>`
URL to complete the tree. Much faster than recursive `/blocks` walking.

### Phase 3: Query each database for entries

```bash
# Use data_source_id (from search results) NOT database_id:
curl -s -X POST "https://api.notion.com/v1/data_sources/{data_source_id}/query" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{}'
```

## API Pitfalls (learned from production audits)

### Teamspaces are invisible
`parent.type` will ALWAYS show `workspace` even for pages in teamspaces.
**Tell the user explicitly** that you can't confirm teamspace placement from the API.

### Two IDs per database — don't mix them
- `database_id` → creating pages: `parent: {"database_id": "..."}`
- `data_source_id` → querying: `POST /v1/data_sources/{id}/query`
- Mixing them returns 400 or 404

### Full UUIDs required for data_source endpoints
`/data_sources/{id}/query` requires complete 36-char UUIDs with dashes.
Search result `id` fields are the full UUID — use those, not truncated snippets.

### ntn needs NOTION_WORKSPACE_ID sometimes
If `ntn` returns "No workspace selected", add:
```bash
export NOTION_WORKSPACE_ID=<any-root-page-uuid>  # any accessible page ID works
```

### POST /search query returns false positives for topic search
`"query": "f1"` or `"query": "formula 1"` matches pages that contain those strings
anywhere in their body, not just in the title. For topic search, fetch ALL pages with
`"query": ""` (empty) and filter titles client-side. See "Topic search" section above.

### Pagination — always loop until has_more is false
A single `page_size: 100` call is not exhaustive. Check `has_more` and loop with
`start_cursor` until it is `false`. Skipping this misses pages beyond position 100.

### 404 on unshared databases
If search finds a DB but query returns 404, the integration wasn't connected to that DB.
User must: Notion UI → DB page → `...` → `Connect to` → integration name.

### markdown > blocks for structure discovery
The `/markdown` endpoint shows `<database>`, `<page>`, `<callout>`, `<columns>` tags
that reveal the actual page structure. `/blocks/{id}/children` returns raw block types
like `child_database` which are harder to interpret. Prefer markdown for hierarchy mapping.

### ntn --json flag gotcha
`ntn api ... --json` is NOT for piping JSON input. Use `--json -` instead:
```bash
echo '{"filter": {...}}' | ntn api v1/data_sources/{id}/query -X POST --json -
```

## Output format

Present results as a **tree diagram** (ASCII or Mermaid) with:

```
WORKSPACE (raíz)
├── 📄 Page Name (subpágina)
│   ├── 📋 DB Name (inline) — N entries
│   │   ├── "Entry 1" — Status: X
│   │   └── "Entry 2" — Status: Y
│   └── 📄 Child page
├── 📋 DB Name (standalone) — N entries
└── 📊 Another DB — N entries
```

Include a summary table at the end:

| Database | Entradas | Ubicación |
|---|---|---|
| Proyectos | 2 | Dentro de Project tracker |
| Ideas | 4 | Workspace raíz |
| ... | ... | ... |

## Helper: parse search results in Python

```python
import json

def parse_search(raw):
    data = json.loads(raw) if isinstance(raw, str) else raw
    items = []
    for r in data.get('results', []):
        obj = r.get('object', '')
        rid = r.get('id', '')
        title = ''
        if 'title' in r:
            title = ''.join(t.get('plain_text', '') for t in r.get('title', []))
        elif 'properties' in r:
            for v in r.get('properties', {}).values():
                if v.get('type') == 'title':
                    title = ''.join(t.get('plain_text', '') for t in v.get('title', []))
        parent = r.get('parent', {})
        pt = parent.get('type', '')
        pp = parent.get('page_id', '') or parent.get('database_id', '') or parent.get('data_source_id', '') or ''
        if pt == 'workspace':
            pp = 'WORKSPACE_ROOT'
        items.append({'obj': obj, 'title': title, 'parent_type': pt, 'parent_id': pp, 'id': rid, 'url': r.get('url', '')})
    return items
```