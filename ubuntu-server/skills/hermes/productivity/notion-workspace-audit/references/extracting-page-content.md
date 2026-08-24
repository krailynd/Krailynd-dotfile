# Extracting Full Page Content (Bulk Read)

When a workspace audit needs the *complete text* of pages — for ranking,
summarizing, comparing, or feeding content to a model — title-only scans are
not enough. The `/markdown` endpoint works for single pages, but for bulk
extraction across many pages with per-block structure control, use recursive
block extraction.

## When to use this vs `/markdown`

| Need | Use |
|------|-----|
| Just get the text of one page | `GET /v1/pages/{id}/markdown` — one call, agent-ready |
| Get text of many pages, fast | `/markdown` per page in a loop |
| Need per-block structure (count B-rolls, isolate headings, filter block types) | Recursive `/blocks` extraction (below) |
| `/markdown` flattens/reorders content in ways that lose meaningful formatting | Recursive `/blocks` extraction (below) |

## Recursive block extraction

`GET /v1/blocks/{block_id}/children` returns only **top-level** blocks. Blocks
with `has_children: true` (`column_list`, `column`, `toggle`, `callout` with
children) need recursive descent — otherwise you get empty shells and miss
the real content inside columns.

```python
import requests

def extract_blocks(block_id, headers, parts=None):
    if parts is None:
        parts = []
    resp = requests.get(
        f"https://api.notion.com/v1/blocks/{block_id}/children?page_size=100",
        headers=headers,
    )
    if resp.status_code != 200:
        return parts
    for block in resp.json().get("results", []):
        btype = block.get("type", "")
        bdata = block.get(btype, {})
        if isinstance(bdata, dict) and "rich_text" in bdata:
            text = "".join(t.get("plain_text", "") for t in bdata["rich_text"])
            if text:
                prefix = ""
                if btype == "heading_1": prefix = "\n# "
                elif btype == "heading_2": prefix = "\n## "
                elif btype == "heading_3": prefix = "\n### "
                elif btype == "bulleted_list_item": prefix = "- "
                elif btype == "numbered_list_item": prefix = "1. "
                elif btype == "callout": prefix = "> "
                elif btype == "quote": prefix = "> "
                parts.append(prefix + text)
        if block.get("has_children"):
            extract_blocks(block["id"], headers, parts)
    return parts
```

## Gotchas

- **`column_list` → `column` → real blocks.** A column_list has column children;
  each column has the actual content blocks as its children. Without recursion
  you see column shells with no text.
- **Use `GET`, not `POST`.** `/v1/blocks/{id}/children` is read-only. A `POST`
  with a JSON body returns `400 validation_error`. (The append-blocks endpoint
  is `PATCH /v1/blocks/{id}/children` with a `children` array.)
- **Pagination: `page_size=100` max.** If a page has >100 top-level blocks,
  loop with `start_cursor` from `next_cursor` while `has_more` is true. Most
  pages are under 100 blocks so the single-call case dominates.
- **`Notion-Version` mixing.** Both `2022-06-28` and `2025-09-03` work for block
  reads. Don't mix versions within a single request set — pick one per script.

## Bulk pattern: query DB → extract every page's full content

```python
# 1. Query all entries (paginate if >100)
all_results = []
cursor = None
while True:
    body = {"page_size": 100}
    if cursor:
        body["start_cursor"] = cursor
    resp = requests.post(
        f"https://api.notion.com/v1/databases/{db_id}/query",
        headers=headers, json=body,
    )
    data = resp.json()
    all_results.extend(data.get("results", []))
    if data.get("has_more") and data.get("next_cursor"):
        cursor = data["next_cursor"]
    else:
        break

# 2. For each entry: extract properties + full content
for r in all_results:
    props = r.get("properties", {})
    # Find title (property name varies — "Name", "Nombre", "Title", etc.)
    title = ""
    for key, val in props.items():
        if val.get("type") == "title":
            title = "".join(t.get("plain_text", "") for t in val.get("title", []))
            break
    # Extract other properties (select, rich_text, status, relation, etc.)
    estado = props.get("Estado", {}).get("status", {}).get("name", "")
    resumen = ""
    rp = props.get("Resumen", {})
    if rp and rp.get("rich_text"):
        resumen = "".join(t.get("plain_text", "") for t in rp["rich_text"])
    # Full block content
    content_parts = extract_blocks(r["id"], headers)
    full_content = "\n".join(content_parts)
    word_count = len(full_content.split())
```

## Verifying the extraction worked

After extracting, sanity-check that `word_count > 0` and that `content_parts`
is non-empty. If a page returns 0 words but you can see content in the Notion
UI, the integration likely lacks access to that page — the user must share it
via `...` → `Connect to` → integration name.
