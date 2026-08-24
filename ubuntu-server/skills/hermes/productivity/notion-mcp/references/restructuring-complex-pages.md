# Restructuring Complex Notion Pages (Multi-DB Read + Batch Update)

When the user asks you to "analyze and improve" or "reorder" a Notion page
that contains multiple inline databases (e.g., a roadmap with 10 phase rows
+ several child databases + intro text blocks), you need a workflow that
goes beyond the single-endpoint recipes in `batch-page-creation.md`.

## When to use this pattern

- "Revisa mi roadmap de Notion y dime cómo mejorarlo"
- "Reordena las fases de mi roadmap"
- "Actualiza los estados de las fases en Notion"
- "Analiza esta parte de mi Notion y mejórala"
- Any task requiring reading multiple DB rows + page blocks, then
  batch-patching properties and rewriting block content in one pass.

## Step 1 — Find the page (search by title)

```python
from dotenv import load_dotenv
import os, json, urllib.request
load_dotenv(os.path.expanduser("~/.hermes/.env"))
TOKEN = os.environ["NOTION_API_KEY"]

def notion_api(endpoint, method="POST", data=None):
    url = f"https://api.notion.com/v1/{endpoint}"
    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(url, data=body, method=method, headers={
        "Authorization": f"Bearer {TOKEN}",
        "Notion-Version": "2022-06-28",
        "Content-Type": "application/json"
    })
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read())

# Search by keyword, NOT exact title — DB-row pages store title in a property
results = notion_api("search", data={"query": "Roadmap", "page_size": 20})
for p in results.get("results", []):
    title = ""
    for k, v in p.get("properties", {}).items():
        if v.get("type") == "title":
            title = "".join(t.get("plain_text","") for t in v.get("title",[]))
    print(f"{title} — {p['id']}")
```

**Pitfall:** Search by exact title may return 0 results if the page is a DB
row (its title is in a property, not page-level metadata). Search by a
keyword from the title. If the first try returns Content Sources or
unrelated pages, try a shorter/broader query.

## Step 2 — Read the full page structure (blocks + child DBs)

```python
page_id = "..."  # from step 1
blocks = notion_api(f"blocks/{page_id}/children", method="GET")

def get_text(block, field):
    return "".join(r.get("plain_text","") for r in block.get(field,{}).get("rich_text",[]))

for b in blocks.get("results", []):
    btype = b.get("type")
    bid = b.get("id")
    has_children = b.get("has_children")
    
    if btype == "child_page":
        print(f"📄 CHILD PAGE: {b['child_page']['title']} [id={bid}]")
    elif btype == "child_database":
        print(f"📊 CHILD DATABASE: {b['child_database']['title']} [id={bid}]")
    elif btype == "heading_2":
        print(f"## {get_text(b, 'heading_2')}")
    elif btype == "paragraph":
        print(f"  {get_text(b, 'paragraph')[:200]}")
    elif btype == "to_do":
        checked = b.get("to_do",{}).get("checked")
        print(f"  [{'x' if checked else ' '}] {get_text(b, 'to_do')}")
    elif btype == "callout":
        print(f"  💡 {get_text(b, 'callout')[:200]}")
    # ... handle bulleted_list_item, numbered_list_item, code, divider, etc.
```

**Key:** `child_database` blocks have their own ID. Use that ID to query
the database (`POST /v1/databases/{db_id}/query`) and read each row. This
is how you get the full content: read blocks for structure, then query
each child DB for the actual data.

## Step 3 — Read each DB row's full properties

```python
db_id = "..."  # from a child_database block
results = notion_api(f"databases/{db_id}/query", method="POST", data={"page_size": 30})

for r in results.get("results", []):
    props = r.get("properties", {})
    title = ""
    for k, v in props.items():
        if v.get("type") == "title":
            title = "".join(t.get("plain_text","") for t in v.get("title",[]))
    
    # Extract by property type:
    # select    → props["X"]["select"]["name"]
    # rich_text → "".join(t.get("plain_text","") for t in props["X"]["rich_text"])
    # status    → props["X"]["status"]["name"]
    # people    → [p.get("name","") for p in props["X"]["people"]]
    
    print(f"{title} — {r['id']}")
```

## Step 4 — Batch-update pages and blocks

### Updating page properties

```python
def update_page(page_id, properties):
    return notion_api(f"pages/{page_id}", method="PATCH",
                      data={"properties": properties})

def rich_text(text):
    return [{"type": "text", "text": {"content": text}}]

import time

update_page(page_id, {
    "Estado": {"select": {"name": "Completado"}},
    "Prioridad": {"select": {"name": "Crítica"}},
    "Duración": {"rich_text": rich_text("8-10 semanas")},
    "Enfoque": {"rich_text": rich_text("Python desde cero hasta intermedio...")},
    "Fase": {"title": rich_text("1 — Python + Programación Real")},  # title prop
})
time.sleep(0.4)  # rate limit: ~3 req/sec
```

### Rewriting existing block content (paragraphs, headings)

To update existing blocks (not append new ones), PATCH the block by ID:

```python
def t(content):
    return {"type": "text", "text": {"content": content}}

def t_bold(content):
    return {"type": "text", "text": {"content": content}, "annotations": {"bold": True}}

for b in blocks.get("results", []):
    if b.get("type") == "paragraph":
        current = "".join(r.get("plain_text","") for r in b.get("paragraph",{}).get("rich_text",[]))
        if "target text snippet" in current:
            notion_api(f"blocks/{b['id']}", method="PATCH", data={
                "paragraph": {"rich_text": [
                    t_bold("REGLA #1: "),
                    t("La IA escribe código, TÚ entiendes qué hace."),
                ]}
            })
```

**Pitfall:** When building `rich_text` arrays with multiple segments, use
helper functions (`t()` and `t_bold()`) — inline JSON with mixed `text`
and `annotations` objects is the #1 cause of Python syntax errors in this
workflow (parenthesis/brace mismatches in heredocs).

## Step 5 — Verify the result

```python
verify = notion_api(f"databases/{db_id}/query", method="POST", data={"page_size": 30})
for r in verify.get("results", []):
    title = "".join(t.get("plain_text","") for t in
                    r.get("properties",{}).get("Fase",{}).get("title",[]))
    estado = r.get("properties",{}).get("Estado",{}).get("select",{})
    estado_name = estado.get("name","") if estado else ""
    icon = "✅" if "Completado" in estado_name else "⭕"
    print(f"{icon} {title} — {estado_name}")
```

## Key pitfalls (learned in production)

1. **Search by exact title misses DB-row pages.** A page inside a database
   has its title in a property. Search by a keyword. Broader is better.

2. **`child_database` blocks need a separate query.** The block children
   endpoint returns `child_database` blocks with an ID but NOT the contents.
   You must `POST /v1/databases/{that_id}/query` to read the rows.

3. **Rate limit between PATCH calls.** Notion allows ~3 req/sec. When
   batch-updating 10+ pages, add `time.sleep(0.4)` between calls. Without
   this, HTTP 429 errors abort the batch mid-way.

4. **`rich_text` with annotations → use helper functions.** Building
   `rich_text` arrays inline with mixed plain text and bold annotations is
   the most common cause of Python syntax errors. Define `t()` and
   `t_bold()` helpers and use them everywhere.

5. **`execute_code` can time out on user approval.** When a script
   modifies Notion (PATCH calls), the sandbox may require user approval.
   If `execute_code` blocks and times out, split the work into smaller
   scripts (2-3 pages each) and run them separately.

6. **Property names are case-sensitive and locale-specific.** A DB created
   in Spanish has "Estado", "Prioridad", "Enfoque" — not "Status",
   "Priority", "Focus". Always read the DB schema first
   (`GET /v1/databases/{id}`) to get exact property names before PATCHing.

7. **You can PATCH block content, not just page properties.** Most Notion
   API guides only show appending blocks. But `PATCH /v1/blocks/{block_id}`
   with a `{"paragraph": {"rich_text": [...]}}` body rewrites the block
   content in-place. This is essential for restructuring intro text without
   deleting and recreating blocks.

## Vision analysis fallback (when vision_analyze tool fails)

If the user sends an image (e.g., a Notion screenshot) and the built-in
`vision_analyze` tool returns a 401 or fails, route through NVIDIA NIM with
a vision-capable model:

```python
import base64
with open(img_path, "rb") as f:
    img_b64 = base64.b64encode(f.read()).decode()

api_key = os.environ["NVIDIA_API_KEY"]
payload = {
    "model": "meta/llama-4-maverick-17b-128e-instruct",
    "messages": [{
        "role": "user",
        "content": [
            {"type": "text", "text": "Describe todo el contenido visible..."},
            {"type": "image_url",
             "image_url": {"url": f"data:image/png;base64,{img_b64}"}}
        ]
    }],
    "max_tokens": 2000
}
req = urllib.request.Request(
    "https://integrate.api.nvidia.com/v1/chat/completions",
    data=json.dumps(payload).encode(), method="POST",
    headers={"Authorization": f"Bearer {api_key}",
             "Content-Type": "application/json"}
)
result = json.loads(urllib.request.urlopen(req, timeout=90).read())
print(result["choices"][0]["message"]["content"])
```

This works when `vision_analyze` is misconfigured (wrong API key routed
via `OPENAI_API_KEY` pointing to an NVIDIA endpoint with wrong key).
The `NVIDIA_API_KEY` env var is the correct one for NIM calls.
