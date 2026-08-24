# Batch Page & Block Operations via Direct API

Session-proven patterns for creating pages with content blocks and embedded
databases via `execute_code` + `urllib.request`. All confirmed working
2026-07-24 against API version `2022-06-28`.

## Critical: PATCH not POST for appending blocks

**The #1 gotcha:** To append child blocks to a page, the HTTP method is
`PATCH`, not `POST`.

```python
# CORRECT — PATCH
req = urllib.request.Request(
    f"https://api.notion.com/v1/blocks/{page_id}/children",
    data=json.dumps({"children": blocks}).encode(),
    method="PATCH",  # <-- THIS
    headers=HEADERS,
)

# WRONG — POST returns HTTP 400 "Invalid request URL"
req = urllib.request.Request(
    f"https://api.notion.com/v1/blocks/{page_id}/children",
    data=json.dumps({"children": blocks}).encode(),
    method="POST",  # <-- FAILS
    headers=HEADERS,
)
```

This affects pages created inside databases too — they CAN have child blocks
appended, but only via `PATCH`.

## Creating a page inside a database (not a standalone page)

When the parent is a database (e.g. "Proyectos Coding"), use
`database_id` parent and the database's title property name:

```python
page = notion_post("https://api.notion.com/v1/pages", {
    "parent": {"database_id": DB_ID},
    "properties": {
        "Name": {  # <-- must match the DB's title property name
            "title": [{"text": {"content": "Page Title"}}]
        }
    }
})
```

**Pitfall:** If you use `"parent": {"page_id": DB_ID}` for a database,
you get HTTP 400. Databases require `database_id` as parent key, and the
property must match the DB's title column name (often `"Name"`, not `"title"`).

## Creating a database inside a page

```python
db = notion_post("https://api.notion.com/v1/databases", {
    "parent": {"type": "page_id", "page_id": PAGE_ID},
    "icon": {"type": "emoji", "emoji": "🗺️"},
    "title": [{"type": "text", "text": {"content": "DB Title"}}],
    "properties": {
        "Name": {"title": {}},
        "Status": {"select": {"options": [
            {"name": "Todo", "color": "gray"},
            {"name": "Doing", "color": "blue"},
            {"name": "Done", "color": "green"},
        ]}},
        "Tags": {"multi_select": {"options": []}},
        "Notes": {"rich_text": {}},
    }
})
```

## Populating a database with multiple entries

```python
entries = [
    {"Name": "Item 1", "Status": "Todo", "Notes": "Detail here"},
    {"Name": "Item 2", "Status": "Done", "Notes": "More detail"},
]

for entry in entries:
    notion_post("https://api.notion.com/v1/pages", {
        "parent": {"database_id": DB_ID},
        "properties": {
            "Name": {"title": [{"text": {"content": entry["Name"]}}]},
            "Status": {"select": {"name": entry["Status"]}},
            "Notes": {"rich_text": [{"text": {"content": entry["Notes"]}}]},
        }
    })
```

**Note:** Notion API does NOT support batch page creation in a single call.
Each page is a separate `POST /v1/pages`. For 50+ entries, add a small
delay (0.1-0.3s) between calls to avoid rate limiting (3 requests/sec).

## Block structure reference

Common block types for content:

```python
# Heading
{"object":"block","type":"heading_1","heading_1":{"rich_text":[{"type":"text","text":{"content":"Title"}}]}}

# Paragraph
{"object":"block","type":"paragraph","paragraph":{"rich_text":[{"type":"text","text":{"content":"Body text"}}]}}

# Divider
{"object":"block","type":"divider","divider":{}}

# To-do item (checked/unchecked)
{"object":"block","type":"to_do","to_do":{"rich_text":[{"type":"text","text":{"content":"Task"}}],"checked":False}}

# Heading 2
{"object":"block","type":"heading_2","heading_2":{"rich_text":[{"type":"text","text":{"content":"Section"}}]}}
```

**Pitfall:** `annotations` (bold, italic) inside rich_text can cause HTTP 400
if the structure is slightly off. When in doubt, omit annotations — plain
`{"type":"text","text":{"content":"..."}}` always works.

## Full pattern: create page → add intro blocks → create DB → populate

```python
# 1. Create page inside a database
page = notion_post("https://api.notion.com/v1/pages", {
    "parent": {"database_id": PARENT_DB_ID},
    "properties": {"Name": {"title": [{"text": {"content": "My Page"}}]}}
})
page_id = page["id"]

# 2. Append intro blocks (PATCH!)
append_blocks(page_id, [
    {"object":"block","type":"heading_1","heading_1":{"rich_text":[{"type":"text","text":{"content":"Title"}}]}},
    {"object":"block","type":"paragraph","paragraph":{"rich_text":[{"type":"text","text":{"content":"Intro text"}}]}},
])

# 3. Create a database inside the page
db = notion_post("https://api.notion.com/v1/databases", {
    "parent": {"type": "page_id", "page_id": page_id},
    "title": [{"type":"text","text":{"content":"My DB"}}],
    "properties": {"Name": {"title": {}}, "Status": {"rich_text": {}}}
})

# 4. Populate the database
for item in items:
    notion_post("https://api.notion.com/v1/pages", {
        "parent": {"database_id": db["id"]},
        "properties": {
            "Name": {"title": [{"text": {"content": item["name"]}}]},
            "Status": {"rich_text": [{"text": {"content": item["status"]}}]},
        }
    })
```

## CRITICAL: Select/multi_select values must match existing options exactly

When creating a page with `select` or `multi_select` properties, the `name` value
**must match** an existing option in the database schema. If it doesn't, the API
returns **HTTP 400 Bad Request** — not a helpful error message saying "option not
found", just a generic 400.

### Before any batch insert: query the database schema

```python
# GET /v1/databases/{db_id} — read the property options
db = notion_api(f"databases/{db_id}", method="GET")
for pname, pval in db.get("properties", {}).items():
    ptype = pval.get("type")
    if ptype == "select":
        opts = [o.get("name") for o in pval.get("select", {}).get("options", [])]
        print(f"{pname} (select): {opts}")
    elif ptype == "multi_select":
        opts = [o.get("name") for o in pval.get("multi_select", {}).get("options", [])]
        print(f"{pname} (multi_select): {opts}")
```

### Common mismatch examples (confirmed in the wild)

| You sent | DB expects | Result |
|----------|-----------|--------|
| `"Básico"` | `"Principiante"` | HTTP 400 |
| `"Español"` | `"ES"` | HTTP 400 |
| `"Libro PDF"` | `"Libro"` | HTTP 400 |
| `"Video Curso"` | `"Curso"` | HTTP 400 |

### Adding new select options via database PATCH does NOT work reliably

The API can auto-create a new select option when you create a page with a
value that doesn't exist yet — but this is inconsistent and sometimes returns
400. Trying to `PATCH /v1/databases/{id}` to rewrite the full `options` array
fails with HTTP 400 if the property already exists. The only reliable path:

1. Create a **single test page** with the new option value.
2. If it succeeds, the option is now auto-created for that database.
3. Proceed with the full batch.

### Pattern for batch page creation in a database with select properties

```python
# Step 1: Query the DB to discover valid option names
db = notion_api(f"databases/{db_id}", method="GET")
valid_niveles = [o["name"] for o in db["properties"]["Nivel"]["select"]["options"]]
valid_tipos = [o["name"] for o in db["properties"]["Tipo"]["select"]["options"]]
# etc.

# Step 2: Query existing entries to avoid duplicate titles
existing = notion_api(f"databases/{db_id}/query", method="POST", data={"page_size": 100})
existing_names = set()
for r in existing.get("results", []):
    for key, val in r.get("properties", {}).items():
        if val.get("type") == "title":
            name = "".join(t.get("plain_text","") for t in val.get("title",[]))
            existing_names.add(name.lower().strip())

# Step 3: Create pages with VALID option names only
for entry in entries:
    if entry["title"].lower().strip() in existing_names:
        continue  # skip duplicate
    notion_api("pages", method="POST", data={
        "parent": {"database_id": db_id},
        "properties": {
            "Recurso": {"title": [{"text": {"content": entry["title"]}}]},
            "Área": {"multi_select": [{"name": entry["area"]}]},
            "Tipo": {"select": {"name": entry["tipo"]}},       # must be in valid_tipos
            "Nivel": {"select": {"name": entry["nivel"]}},      # must be in valid_niveles
            "Idioma": {"select": {"name": entry["idioma"]}},   # must match valid options
            "Gratis": {"checkbox": True},
            "Link": {"url": entry["link"]},
            "Por qué / Notas": {"rich_text": [{"text": {"content": entry["notes"]}}]},
        }
    })
    time.sleep(0.35)  # rate limit: 3 req/sec
```

### Deducing duplicates from a query

Notion API has no "upsert" — duplicate detection is manual:
1. Query all existing pages (`POST /databases/{id}/query`)
2. Extract the title from each page's title property
3. Build a `set` of lowercase titles
4. Skip entries whose title is already in the set

## Rate limit note

Notion API allows ~3 requests/second. For large batch operations (50+ pages),
add `time.sleep(0.35)` between calls or use exponential backoff on 429 responses.
