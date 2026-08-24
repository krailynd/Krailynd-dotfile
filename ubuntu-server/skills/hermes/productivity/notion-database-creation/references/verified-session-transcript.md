# Full verified creation transcript — 2026-07-12 session

This documents the exact sequence that successfully created "Proyectos Saha" → "Proyectos" database with 9 custom properties in Krailynd's Notion workspace.

## Environment
- API: Notion REST API v2025-09-03
- Auth: Internal integration token (NOTION_API_KEY)
- Tool: curl + python3 for JSON parsing
- Workspace root page: "Project tracker" (2dfdfc0a-a985-80de-bc3b-c376bd4b0f18)

## Sequence

### 1. Create container page
```bash
POST /v1/pages
parent: {"page_id": "2dfdfc0a-a985-80de-bc3b-c376bd4b0f18"}  # workspace root
properties: {"title": [{"text": {"content": "Proyectos Saha"}}]}
icon: {"type": "emoji", "emoji": "📂"}
→ Result: page_id = 39bdfc0a-a985-8179-8734-e9de2b8a3f6c
```

### 2. Create database shell
```bash
POST /v1/databases
parent: {"type": "page_id", "page_id": "39bdfc0a-a985-8179-8734-e9de2b8a3f6c"}
title: [{"text": {"content": "Proyectos"}}]
properties: {"Nombre": {"title": {}}}  # only title — rest ignored here
→ Result: database_id = 3182f4ae-5248-4336-8c7f-8a9d9ac61297
          data_source_id = dc875fd8-70c5-48c1-8253-969dab9c75dd
```

### 3. Attempt 1 (FAILED): PATCH /databases with all props
PATCH /v1/databases/3182f4ae-... with all 7 custom properties in one call
→ Returned OK but GET /data_sources showed only Name + Estado
→ Lesson: databases endpoint doesn't reliably accept property patches in v2025-09-03

### 4. PATCH data_sources in batches (SUCCESS)
```bash
# Batch A: Estado (status)
PATCH /v1/data_sources/dc875fd8-... → OK, verified

# Batch B: Fecha Inicio + Fecha Entrega (date)
PATCH /v1/data_sources/dc875fd8-... → OK

# Batch C: Lenguajes (multi_select, 18 options)
PATCH /v1/data_sources/dc875fd8-... → OK

# Batch D: Categoría (select) + Descripción (rich_text) + Repositorio (url) + Prioridad (select)
PATCH /v1/data_sources/dc875fd8-... → OK
```

### 5. Verify final schema
```bash
GET /v1/data_sources/dc875fd8-...
→ 9 properties confirmed:
  Categoría: select
  Descripción: rich_text
  Estado: status
  Fecha Entrega: date
  Fecha Inicio: date
  Lenguajes: multi_select
  Name: title
  Prioridad: select
  Repositorio: url
```

### 6. Create first project item
```bash
POST /v1/pages
parent: {"database_id": "3182f4ae-..."}
properties: {
  "Name": {"title": [{"text": {"content": "SahaCloud Platform"}}]},
  "Estado": {"status": {"name": "En Proceso"}},
  ...all other props filled
}
→ Result: page_id = 39bdfc0a-a985-81b7-aa4a-c7c89e0f80e9
```

### 7. Add documentation blocks to project page
```bash
PATCH /v1/blocks/39bdfc0a-.../children
children: [heading_2, paragraph, bulleted_list_item × 5, heading_2, bulleted_list_item × 3, heading_2, numbered_list_item × 3]
→ 17 blocks added successfully
```

## Post-creation issue encountered
User renamed the container page to "Proyectos Coding" and moved it inside another database. The new parent database was NOT shared with the integration → API returned 404 on parent data_source and page title appeared as "sin título". The inner "Proyectos" DB and its items remained accessible.

## Unicode note
Property names with accents (Categoría, Descripción) work in curl when the shell/terminal sends proper UTF-8. In Python scripts or JSON files, use Unicode escapes (\u00ed, \u00f3) to be safe.