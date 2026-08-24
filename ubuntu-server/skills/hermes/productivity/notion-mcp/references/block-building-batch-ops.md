# Block Building & Batch Content Operations

Session-proven patterns for programmatically building rich Notion pages with
dozens of blocks via `execute_code` + `urllib.request`. Confirmed working
2026-07-26 against API version `2022-06-28`.

## Helper functions for rich text with annotations

When building blocks in Python, define helper functions to avoid repetitive
JSON and annotation errors:

```python
def t(text):
    """Plain text"""
    return {"type": "text", "text": {"content": text}}

def t_bold(text):
    """Bold text"""
    return {"type": "text", "text": {"content": text}, "annotations": {"bold": True}}

def t_italic(text):
    """Italic text"""
    return {"type": "text", "text": {"content": text}, "annotations": {"italic": True}}

def t_code(text):
    """Inline code"""
    return {"type": "text", "text": {"content": text}, "annotations": {"code": True}}
```

Usage in a block:
```python
{"type": "paragraph", "paragraph": {"rich_text": [
    t_bold("Para qué sirve: "),
    t("El gradient descent es cómo aprenden las redes neuronales.")
]}}
```

## Block type reference (all confirmed working)

### Headings
```python
{"type": "heading_1", "heading_1": {"rich_text": [t("Title")]} \
    # Optional: "is_toggleable": True
{"type": "heading_2", "heading_2": {"rich_text": [t("Section")]}
{"type": "heading_3", "heading_3": {"rich_text": [t("Subsection")]}
```

### Paragraphs and lists
```python
{"type": "paragraph", "paragraph": {"rich_text": [t("Body")]} \
    # Multiple rich_text elements: [t_bold("Label: "), t("value")]
{"type": "bulleted_list_item", "bulleted_list_item": {"rich_text": [t("Item")]} \
{"type": "numbered_list_item", "numbered_list_item": {"rich_text": [t("Step")]} \
{"type": "to_do", "to_do": {"rich_text": [t("Task")], "checked": false} \
```

### Callouts and dividers
```python
# Callout — emoji must be the UNICODE EMOJI CHARACTER, not a name string
{"type": "callout", "callout": {
    "rich_text": [t("Important note")],
    "icon": {"type": "emoji", "emoji": "\U0001F4CB"}  # 📋 — unicode escapes work
}}

# Divider
{"type": "divider", "divider": {}}
```

### Special blocks
```python
# Code block
{"type": "code", "code": {"rich_text": [t("print('hello')")], "language": "python"}}

# Quote
{"type": "quote", "quote": {"rich_text": [t("Quoted text")} \
```

## CRITICAL PITFALLS (all hit in production)

### Pitfall 1: Emoji in callout must be unicode, not a name

```python
# WRONG — HTTP 400
"icon": {"type": "emoji", "emoji": "objective"}

# RIGHT — actual emoji character
"icon": {"type": "emoji", "emoji": "\U0001F3AF"}  # 🎯
# or the literal emoji:
"icon": {"type": "emoji", "emoji": "target"}  # Only if "target" is not a valid emoji
```

The API expects an actual emoji character (`"🎯"`), not an emoji name (`"objective"`
or `"target"`). When writing Python source that may get mangled by encoding
issues, use unicode escapes: `"\U0001F3AF"` for 🎯, `"\U0001F4CB"` for 📋.

### Pitfall 2: Mixed quote characters in Python strings

When building blocks with text containing apostrophes or quotes, Python's
string quoting can silently corrupt the JSON. Example that broke:

```python
# BROKEN — the ' creates a Python syntax issue when mixed with " in JSON
t("Fine-tuning es como adaptas un LLM. Si sabes LoRA, ya sabes hacer lo que startups pagan: adaptar modelos a casos reales.')]}}
#                                                                        ^^^ stray ')]

# FIX — keep the string clean, use only double quotes for the JSON
t("Fine-tuning es como adaptas un LLM. Si sabes LoRA, ya sabes hacer lo que startups pagan.")]}}
```

**Rule:** When writing blocks in Python files, avoid apostrophes inside
`t("...")` strings. Use "醋" (unicode) or rephrase. Or write the script to
a file first and validate with `python3 -c "import ast; ast.parse(open('script.py').read())"`
before executing.

### Pitfall 3: Missing closing brace in block dicts

Block dicts have nested structure: `{"type": ..., "type_name": {"rich_text": [...]}} \
A common error is `]}"` instead of `]}}` — missing one closing brace.

```python
# WRONG — missing one }
{"type": "numbered_list_item", "numbered_list_item": {"rich_text": [t("text")]}, \
#                                                                  ^^^ only 1 } before comma

# RIGHT — two closing braces
{"type": "numbered_list_item", "numbered_list_item": {"rich_text": [t("text")]}} \
#                                                                   ^^ two } \
```

### Pitfall 4: Batch size limit

Notion API allows up to 100 children blocks per PATCH request. For pages with
more content, split into multiple PATCH calls:

```python
# Batch 1: first 45 blocks
notion_api(f"blocks/{page_id}/children", method="PATCH", data={"children": blocks_1})

# Batch 2: next 47 blocks
notion_api(f"blocks/{page_id}/children", method="PATCH", data={"children": blocks_2})
```

In practice, keep batches at ~45-70 blocks to avoid timeouts on slow connections.

### Pitfall 5: Runtime errors from execute_code on large scripts

When building pages with 100+ blocks, the Python script gets long. `execute_code`
may time out or hit the 50KB stdout limit. Solution:

1. Write the script to a file with `write_file` (validated by syntax checker)
2. Run it with `terminal` instead of `execute_code`
3. Save the `page_id` to a temp file so subsequent batches can read it

```python
# At the end of the script:
with open("/tmp/schedule_page_id.txt", "w") as f:
    f.write(page_id)
```

## Pattern: Create a page with 100+ blocks in batches

```python
# Step 1: Create the empty page
page = notion_api("pages", method="POST", data={
    "parent": {"page_id": PARENT_PAGE_ID},
    "properties": {"title": {"title": [{"text": {"content": "My Page"}}]}},
    "children": []  # no children at creation
})
page_id = page["id"]

# Step 2: Write blocks to a file, validate, run in batches
# (use write_file + terminal instead of execute_code for reliability)

# batch_1 = [...45 blocks...]
# batch_2 = [...47 blocks...]
# batch_3 = [...32 blocks...]
# batch_4 = [...71 blocks...]

# Each batch:
notion_api(f"blocks/{page_id}/children", method="PATCH", data={"children": batch_N})

# Step 3: If page_id needs to persist across batches, save to temp file
with open("/tmp/my_page_id.txt", "w") as f:
    f.write(page_id)
```

## Pattern: Scraping a directory site and loading resources into Notion

Combined workflow: navigate a file directory site (like elhacker.info) → extract
all links → filter by relevance → deduplicate against existing entries → batch
insert into a Notion database.

```python
# 1. Navigate the site with browser_navigate → snapshot gives all links

# 2. Filter for relevant resources (by URL pattern, link text, or category)
#    Don't upload everything — curate for the specific goal

# 3. Query existing DB entries to build a dedup set
existing = notion_api(f"databases/{db_id}/query", method="POST", data={"page_size": 100})
existing_names = set()
for r in existing.get("results", []):
    for key, val in r.get("properties", {}).items():
        if val.get("type") == "title":
            name = "".join(t.get("plain_text","") for t in val.get("title",[]))
            existing_names.add(name.lower().strip())

# 4. Insert in batches of 15-20 with 0.35s delay (rate limit)
#    Always check existing_names BEFORE creating to skip duplicates

# 5. After all batches, query the DB one more time to verify total count
results = notion_api(f"databases/{db_id}/query", method="POST", data={"page_size": 100})
print(f"Total entries: {len(results['results'])}")
```

## Pattern: Updating existing database entries by page ID

When you need to modify properties of entries already in a database (not create
new ones), use PATCH on each page:

```python
# Update several pages' properties by ID
phase_ids = {
    "0": "page-id-here",
    "1": "another-page-id",
}

for phase_num, pid in phase_ids.items():
    notion_api(f"pages/{pid}", method="PATCH", data={
        "properties": {
            "Estado": {"select": {"name": "Completado"}},  # must be valid option
            "Duración": {"rich_text": [{"text": {"content": "8-10 semanas"}}]},
            "Fase": {"title": [{"text": {"content": "New Title"}}]},
        }
    })
    time.sleep(0.35)
```

**Pitfall:** When updating a `title` property via PATCH, wrap it in `"title": [{"text": {"content": "..."}}]`,
not `"rich_text"`. The title property type requires `"title"` key, not `"rich_text"`.

**Pitfall:** When updating `select` properties, the `name` must match an existing
option. Auto-creation of new options via page PATCH does not always work —
query the database schema first (see `batch-page-creation.md`).
