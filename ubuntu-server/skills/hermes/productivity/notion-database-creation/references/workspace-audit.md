# Notion Workspace Structure Audit (via REST API)

How to reconstruct a user's Notion hierarchy — pages, databases, items — when they say
"revisa cómo está organizado mi Notion", "dónde está cada cosa", or "audita mi workspace".

## Critical limitation: Teamspaces are invisible

As of API v2025-09-03, Notion's REST API does **not** expose teamspaces.
Search results show `parent.type: "workspace"` for root-level pages and
`parent.type: "page_id"` / `parent.type: "database_id"` / `parent.type: "data_source_id"`
for nested items — but **never** `parent.type: "teamspace_id"`.

When the user says "moví cosas al espacio de equipo 'coding'" or "el teamspace 'krailynd'",
you cannot verify teamspace membership from the API. **Be honest about this limitation**
and ask the user to confirm from the UI.

## Step-by-step audit flow

### 1. Find the root workspace pages

```bash
export NOTION_API_TOKEN=$NOTION_API_KEY NOTION_KEYRING=0
ntn api v1/search query=""  # empty query = broad workspace search
```

Filter for `"parent": {"type": "workspace"}` — these are the top-level pages
visible at the workspace root (not inside teamspaces).

### 2. For each root page, read its Markdown

```bash
ntn api v1/pages/{page_id}/markdown
```

This is the **golden technique**. The Markdown representation shows:
- `<page url="...">Title</page>` — linked child pages
- `<database url="..." inline="true" data-source-url="collection://UUID">Title</database>` — inline databases with their `data_source_id`
- `<columns>` / `<column>` / `<callout>` — layout structure

Parse these to build the tree without needing recursive block children calls.

### 3. Resolve inline databases

For each database found in step 2, get metadata and entries:

```bash
# Get database title + schema
ntn api v1/data_sources/{data_source_id}

# Get entries
ntn api v1/data_sources/{data_source_id}/query -X POST
```

### 4. Cross-reference with broad searches

Search for specific terms the user mentions (project names, DB titles, "tracker", etc.):

```bash
ntn api v1/search query="proyectos youtube"
ntn api v1/search query="ideas"
ntn api v1/search query="project tracker"
```

Some items may appear in search even if they weren't linked from the root page
(e.g., databases created via UI that weren't embedded in any page).

### 5. Handle orphaned items

Items with `parent.type: "database_id"` that don't appear in any inspected page
may belong to databases not shared with the integration, or to teamspaces.
**404 on data_source lookup means the integration lacks access** — tell the user
to share that database with the integration from the Notion UI.

## Output format for the user

Present findings in a clear table/map, distinguishing:

| Lo que encontré | Dónde está |
|---|---|
| ... | ... |

Add a separate section for **Lo que NO encontré** with items the user mentioned
but didn't appear in API results, explaining the likely reason (teamspace limitation,
missing integration share, etc.).

## Quirks discovered

- `ntn api v1/search` without a query param returns `400 Bad Request` — always pass `query=...`
- `child_database` block type appears in `/blocks/{id}/children` responses but
  `/pages/{id}/markdown` is far more useful for structure mapping
- Some inline databases return 404 on data_source lookup — likely database templates
  or databases the integration wasn't shared with
- Database items created via UI may have `parent.data_source_id` while items created
  via API have `parent.database_id` — both work for lookup
- `/pages/{id}/markdown` is truncated=false for most pages — safe to rely on it for
  full structure
- Callouts with empty rich_text but containing inline databases are common in
  Project tracker-style pages