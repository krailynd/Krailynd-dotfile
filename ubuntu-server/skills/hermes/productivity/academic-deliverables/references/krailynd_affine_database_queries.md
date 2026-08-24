# Krailynd AFFiNE Database Queries Reference

> **Scope:** Self-hosted AFFiNE instance at `draw.sahacloud.dpdns.org`
> **Database:** PostgreSQL (container: `sahacloud-affine-postgres`)
> **User:** `affine` | **Database:** `affine_db` | **Password:** `YOUR_AFFINE_DB_PASSWORD`
> **Workspace ID:** `4ace6ac3-7518-41d6-9672-85f08c8eafa1`

---

## 🔍 Core Tables for Note Retrieval

### 1. Workspaces
```sql
SELECT id, name, created_at FROM workspaces;
```
**Krailynd's workspace:**
- ID: `4ace6ac3-7518-41d6-9672-85f08c8eafa1`
- Name: `Krailynd`
- Created: `2026-06-30 01:07:50.446+00`

### 2. Workspace Pages (Documents/Notes)
```sql
SELECT 
    page_id, 
    title, 
    summary, 
    mode, 
    published_at,
    blocked
FROM workspace_pages 
WHERE workspace_id = '4ace6ac3-7518-41d6-9672-85f08c8eafa1' 
ORDER BY published_at DESC NULLS LAST, title ASC;
```

**Fields:**
- `page_id`: Unique identifier for the document
- `title`: Document title (may be empty)
- `summary`: Auto-generated summary or first line of content
- `mode`: Type of document (0 = standard, 1 = edgeless, 2 = database)
- `published_at`: Timestamp when document was published
- `blocked`: Boolean indicating if document is blocked

### 3. Blobs (Document Content)
```sql
SELECT 
    id, 
    workspace_id, 
    page_id, 
    created_at,
    updated_at
FROM blobs 
WHERE workspace_id = '4ace6ac3-7518-41d6-9672-85f08c8eafa1' 
ORDER BY updated_at DESC;
```

**Note:** Blob content is stored as binary JSON in the `content` column. Use:
```sql
SELECT 
    id, 
    page_id, 
    created_at,
    encode(digest(content, 'sha256'), 'hex') as content_hash
FROM blobs 
WHERE workspace_id = '4ace6ac3-7518-41d6-9672-85f08c8eafa1' 
ORDER BY created_at DESC;
```

### 4. Snapshots (Historical Versions)
```sql
SELECT 
    id, 
    workspace_id, 
    blob_id, 
    created_at
FROM snapshots 
WHERE workspace_id = '4ace6ac3-7518-41d6-9672-85f08c8eafa1' 
ORDER BY created_at DESC 
LIMIT 20;
```

---

## 📋 Pre-Built Queries for Common Tasks

### Query 1: List All Documents with Titles
```sql
SELECT 
    wp.page_id,
    COALESCE(wp.title, '(Sin título)') as title,
    COALESCE(wp.summary, '') as summary,
    wp.published_at,
    CASE wp.mode
        WHEN 0 THEN 'Documento'
        WHEN 1 THEN 'Lienzo'
        WHEN 2 THEN 'Base de datos'
        ELSE 'Desconocido'
    END as type
FROM workspace_pages wp
WHERE wp.workspace_id = '4ace6ac3-7518-41d6-9672-85f08c8eafa1'
ORDER BY wp.published_at DESC NULLS LAST, wp.title ASC;
```

### Query 2: Count Documents by Type
```sql
SELECT 
    mode,
    COUNT(*) as count,
    CASE mode
        WHEN 0 THEN 'Documento'
        WHEN 1 THEN 'Lienzo'
        WHEN 2 THEN 'Base de datos'
        ELSE 'Desconocido'
    END as type
FROM workspace_pages 
WHERE workspace_id = '4ace6ac3-7518-41d6-9672-85f08c8eafa1'
GROUP BY mode;
```

### Query 3: Find Recently Updated Documents
```sql
SELECT 
    wp.page_id,
    COALESCE(wp.title, '(Sin título)') as title,
    wp.updated_at
FROM workspace_pages wp
WHERE wp.workspace_id = '4ace6ac3-7518-41d6-9672-85f08c8eafa1'
  AND wp.published_at > NOW() - INTERVAL '7 days'
ORDER BY wp.published_at DESC;
```

### Query 4: Search for Specific Document by Title
```sql
SELECT 
    page_id,
    title,
    summary
FROM workspace_pages 
WHERE workspace_id = '4ace6ac3-7518-41d6-9672-85f08c8eafa1'
  AND LOWER(title) LIKE LOWER('%estática%')
ORDER BY published_at DESC;
```

### Query 5: Get Full Document Content (JSON)
```sql
SELECT 
    b.content
FROM blobs b
JOIN workspace_pages wp ON b.page_id = wp.page_id
WHERE b.workspace_id = '4ace6ac3-7518-41d6-9672-85f08c8eafa1'
  AND wp.title = 'Nueva idea YouTube'
ORDER BY b.created_at DESC 
LIMIT 1;
```

**Note:** The `content` column contains the full document in AFFiNE's internal JSON format. To extract readable text, you may need to parse the JSON structure.

---

## 🛠️ Command-Line Access

### Connect to PostgreSQL
```bash
docker exec -it sahacloud-affine-postgres psql -U affine -d affine_db
```

### Run Query Directly
```bash
docker exec sahacloud-affine-postgres psql -U affine -d affine_db -c "
SELECT page_id, title, published_at 
FROM workspace_pages 
WHERE workspace_id = '4ace6ac3-7518-41d6-9672-85f08c8eafa1' 
ORDER BY published_at DESC;"
```

### Export All Pages to CSV
```bash
docker exec sahacloud-affine-postgres psql -U affine -d affine_db -c "
COPY (
    SELECT page_id, title, summary, published_at
    FROM workspace_pages 
    WHERE workspace_id = '4ace6ac3-7518-41d6-9672-85f08c8eafa1'
) TO STDOUT WITH CSV HEADER;" > /tmp/krailynd_affine_pages.csv
```

---

## 📊 Current Krailynd's AFFiNE Workspace (2026-07-06)

### Workspace Info
- **ID:** `4ace6ac3-7518-41d6-9672-85f08c8eafa1`
- **Name:** `Krailynd`
- **Owner:** YOUR_NAME (`YOUR_VIVALDI_EMAIL`)
- **Created:** 2026-06-30 01:07:50.446+00
- **Total Documents:** 16

### Document List (as of 2026-07-06)
| Page ID | Title | Type | Summary |
|---------|-------|------|---------|
| yaXMip2n5YlwQvphWywo0 | (Sin título) | Documento | - |
| l7k7Gg1mqN7cgIBxK29gl | (Sin título) | Documento | - |
| Zjj549fr0f823HMyubY6k | (Sin título) | Documento | - |
| ObD3rrXgBPgWNl3Zh35xt | 2026-07-05 | Documento | - |
| xmRj4MV7w7Am-ReWZuP9Y | Estatica | Documento | - |
| EQuuWvvi6c | Getting Started | Documento | Welcome to AFFiNE! You can start... |
| OELl637r0t | How to use folder and Tags | Documento | Create folder, and move docs into... |
| nY2tRTtuRd4GcskFlCIPq | Ideas para videos | Documento | - |
| AGfRCSBwVSlC-AOgvm1Hv | ideas shorts | Documento | Primera entrada de ideas para... |
| 0UeW24ywj2CMmTtwk_qtm | Nota de prueba Hermes | Documento | Contenido de prueba escrito por... |
| b4BEpj6LcOw7h9dtHIH01 | Nueva idea YouTube | Documento | Idea inicial: video sobre productividad... |
| UqxfGiUs1cP_aNMvYLEC3 | Prueba plantilla investigacion | Documento | Pregunta a responder:Fuentes revisadas... |
| u3eVqOgTmKp0v543KKHm_ | SahaDisk | Documento | Rutas de Open-SahaDisk┌─────────────────... |
| SQyRAVo7c- | SahaDisk Rutas y Recompilación | Documento | Gestión y Desarrollo de SahaDisk... |
| z32SivYsCe8yl5IsZTFpB | Un dia en la vida de un estudiante de ing sistemas | Documento | - |
| 48H-B7QGKGHQz9UdkEbLd | Upsjb | Documento | - |

---

## 🔗 Web Interface Access

### Direct Navigation
- **URL:** `https://draw.sahacloud.dpdns.org/`
- **Authentication:** Session-based (no login required for Krailynd's self-hosted instance)

### Browser Automation
Use `browser_navigate` to access AFFiNE, then:
1. Click "All docs" to see document list
2. Click on document title to view content
3. Use `browser_snapshot` to extract text content

**Note:** AFFiNE's web interface uses React and may require JavaScript execution for full functionality.

---

## ⚠️ Important Notes

1. **No Local File Storage**: AFFiNE stores documents in PostgreSQL, not as files in the filesystem. The directory `/home/YOUR_USER/.affine/storage/` contains only binary blobs (images, attachments).

2. **Database Dependencies**: The AFFiNE instance uses:
   - PostgreSQL container: `sahacloud-affine-postgres`
   - Redis container: `sahacloud-affine-redis`
   - Main container: `sahacloud-affine`

3. **Backup Location**: All AFFiNE data is persisted in:
   - PostgreSQL: `/home/YOUR_USER/.affine/postgres/`
   - Redis: `/home/YOUR_USER/.affine/redis/`
   - Storage: `/home/YOUR_USER/.affine/storage/`

4. **Time Zone**: Server is in UTC. Krailynd's local time is UTC-5 (Perú).

---

## 📝 Example: Retrieving Full Document Content

To get the full content of "Nueva idea YouTube":

```bash
# Step 1: Get the page_id
PAGE_ID=$(docker exec sahacloud-affine-postgres psql -U affine -d affine_db -t -c "
    SELECT page_id FROM workspace_pages 
    WHERE workspace_id = '4ace6ac3-7518-41d6-9672-85f08c8eafa1' 
      AND title = 'Nueva idea YouTube';" | xargs)

# Step 2: Get the blob content
BLOB_CONTENT=$(docker exec sahacloud-affine-postgres psql -U affine -d affine_db -t -c "
    SELECT content FROM blobs 
    WHERE workspace_id = '4ace6ac3-7518-41d6-9672-85f08c8eafa1' 
      AND page_id = '$PAGE_ID' 
    ORDER BY created_at DESC 
    LIMIT 1;" | xargs)

# Step 3: Save to file
echo "$BLOB_CONTENT" > /tmp/nueva_idea_youtube.json
```

The JSON content will need to be parsed to extract the actual document text. AFFiNE uses a custom block-based format.

---

## 🔄 Maintenance Commands

### Backup Database
```bash
docker exec sahacloud-affine-postgres pg_dump -U affine affine_db > /tmp/affine_db_backup_$(date +%Y%m%d).sql
```

### Restore Database
```bash
cat /tmp/affine_db_backup.sql | docker exec -i sahacloud-affine-postgres psql -U affine -d affine_db
```

### Restart AFFiNE Stack
```bash
cd ~/sahacloud-infra/stacks/affine
docker compose down && docker compose up -d
```