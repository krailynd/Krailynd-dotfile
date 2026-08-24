---
name: notion-database-creation
description: "Notion API techniques: database creation with custom properties, workspace structure auditing, and hierarchy reconstruction via REST API v2025-09-03. Complements the bundled 'notion' skill."
version: 1.0.0
author: hermes
license: MIT
platforms: [linux, macos, windows]
prerequisites:
  env_vars: [NOTION_API_KEY]
  skills: [notion]
metadata:
  hermes:
    tags: [Notion, Database, API, curl]
---

# Notion Database Creation (API v2025-09-03)

The bundled `notion` skill documents `POST /v1/data_sources` for database creation — this endpoint **no longer works** in v2025-09-03. This skill provides the verified 3-step flow.

## When to use this skill

- Creating a new Notion database with custom properties via the REST API (curl)
- The user asks "crea una base de datos en Notion con campos X, Y, Z"
- `POST /v1/data_sources` returns "Use the Create Database API instead"
- **Auditing workspace structure**: the user asks "revisa dónde está cada cosa", "cómo está organizado mi Notion", "audita mi workspace" — see `references/workspace-audit.md` for the full technique

## Verified 3-step flow

### Step 1: Create database shell

`POST /v1/databases` with ONLY the title property. Custom properties passed here are **silently ignored**.

```bash
curl -s -X POST "https://api.notion.com/v1/databases" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{
    "parent": {"type": "page_id", "page_id": "PARENT_UUID"},
    "icon": {"type": "emoji", "emoji": "💻"},
    "title": [{"text": {"content": "DB Name"}}],
    "properties": {"Name": {"title": {}}}
  }'
```

⚠️ `parent` MUST include `"type": "page_id"`. Omitting it returns validation error.

Save the returned `id` (database_id) and `data_sources[0].id` (data_source_id).

### Step 2: Add custom properties in batches

Use `PATCH /v1/data_sources/{data_source_id}`. **Batch 2-3 properties per call** — large single batches can silently drop properties.

```bash
# Batch: status + dates
curl -s -X PATCH "https://api.notion.com/v1/data_sources/{ds_id}" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{
    "properties": {
      "Estado": {
        "status": {
          "options": [
            {"name": "Pendiente", "color": "gray"},
            {"name": "En Proceso", "color": "blue"},
            {"name": "Finalizado", "color": "green"}
          ],
          "groups": [
            {"name": "Activos", "color": "blue", "option_ids": []},
            {"name": "Cerrados", "color": "green", "option_ids": []}
          ]
        }
      },
      "Fecha Inicio": {"date": {}},
      "Fecha Entrega": {"date": {}}
    }
  }'
```

Repeat for: multi_select options, select options, rich_text, url, number, etc.

### Step 3: Verify

```bash
curl -s "https://api.notion.com/v1/data_sources/{ds_id}" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2025-09-03" | jq '.properties | keys'
```

### Step 4: Create items using `database_id`

```bash
curl -s -X POST "https://api.notion.com/v1/pages" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{
    "parent": {"database_id": "DB_UUID"},
    "properties": {
      "Name": {"title": [{"text": {"content": "Item name"}}]},
      "Estado": {"status": {"name": "Pendiente"}}
    }
  }'
```

## Quirks reference

| Quirk | Fix |
|---|---|
| `POST /v1/data_sources` for new DBs rejected | Use `POST /v1/databases` |
| Parent missing `type` field | Always set `"type": "page_id"` |
| Custom props in POST silently dropped | PATCH data_sources after creation |
| Single huge PATCH drops props | Batch 2-3 props per call |
| `GET /v1/databases/{id}` no properties | Use `GET /v1/data_sources/{id}` |
| Accented chars (á, é, í) in JSON keys | Use Unicode escapes or ensure UTF-8 |
| Page moved to unshared container | User must re-share with integration |
| Title property is `Name` not `Nombre` | API uses English property keys |

## Property type quick reference

- **status**: `{"status": {"options": [...], "groups": [...]}}`
- **select**: `{"select": {"options": [{"name": "X", "color": "blue"}, ...]}}`
- **multi_select**: `{"multi_select": {"options": [...]}}`
- **date**: `{"date": {}}`
- **rich_text**: `{"rich_text": {}}`
- **url**: `{"url": {}}`
- **number**: `{"number": {"format": "number"}}`
- **title**: `{"title": {}}` (only one per DB, already created in step 1)

## Adding documentation to a database item

After creating a page in the database, add content blocks:

```bash
curl -s -X PATCH "https://api.notion.com/v1/blocks/{page_id}/children" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{
    "children": [
      {"object": "block", "type": "heading_2", "heading_2": {"rich_text": [{"text": {"content": "Section title"}}]}},
      {"object": "block", "type": "paragraph", "paragraph": {"rich_text": [{"text": {"content": "Body text here."}}]}},
      {"object": "block", "type": "bulleted_list_item", "bulleted_list_item": {"rich_text": [{"text": {"content": "Bullet point"}}]}}
    ]
  }'
```

Max ~100 blocks per call. For larger docs, split into multiple PATCH calls.