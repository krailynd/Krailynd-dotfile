# Krailynd's AFFiNE Workspace Reference

> **Last Updated:** 2026-07-06
> **Workspace:** `draw.sahacloud.dpdns.org` (Self-hosted AFFiNE)
> **Owner:** YOUR_NAME (Krailynd)
> **Email:** YOUR_VIVALDI_EMAIL

---

## 📌 Quick Reference

| Property | Value |
|----------|-------|
| **Workspace ID** | `4ace6ac3-7518-41d6-9672-85f08c8eafa1` |
| **Workspace Name** | `Krailynd` |
| **Owner Name** | YOUR_NAME |
| **Created** | 2026-06-30 01:07:50.446+00 |
| **Current Document Count** | 16 (as of 2026-07-06) |

---

## 🔗 Access Information

### Web Interface
- **URL:** https://draw.sahacloud.dpdns.org/
- **Authentication:** Session-based (no login required for self-hosted instance)
- **Admin Email:** YOUR_VIVALDI_EMAIL
- **Admin Password:** YOUR_AFFINE_ADMIN_PASSWORD (set in affine.env)

### Database Access
- **Container:** `sahacloud-affine-postgres`
- **User:** `affine`
- **Database:** `affine_db`
- **Password:** `YOUR_AFFINE_DB_PASSWORD` (from affine.env)
- **Port:** 5432 (internal, on `affine-internal` network)

### Docker Stack
```bash
# Location
~/sahacloud-infra/stacks/affine/

# Containers
- sahacloud-affine (main application)
- sahacloud-affine-postgres (PostgreSQL 16 with pgvector)
- sahacloud-affine-redis (Redis 7)
- sahacloud-affine-migration (one-time migration job)

# Compose command
cd ~/sahacloud-infra/stacks/affine
docker compose up -d
```

### Data Persistence
```
PostgreSQL: /home/YOUR_USER/.affine/postgres/
Redis:      /home/YOUR_USER/.affine/redis/
Storage:    /home/YOUR_USER/.affine/storage/
Config:     /home/YOUR_USER/.affine/config/
```

---

## 📋 Current Workspace Contents (2026-07-06)

### Document List (All 16 Documents)

| # | Page ID | Title | Type | Summary | Published At |
|---|---------|-------|------|---------|--------------|
| 1 | EQuuWvvi6c | Getting Started | Document | Welcome to AFFiNE! You can start... | - |
| 2 | OELl637r0t | How to use folder and Tags | Document | Create folder, and move docs into... | - |
| 3 | ObD3rrXgBPgWNl3Zh35xt | 2026-07-05 | Document | - | - |
| 4 | xmRj4MV7w7Am-ReWZuP9Y | Estatica | Document | - | - |
| 5 | nY2tRTtuRd4GcskFlCIPq | Ideas para videos | Document | - | - |
| 6 | AGfRCSBwVSlC-AOgvm1Hv | ideas shorts | Document | Primera entrada de ideas para... | - |
| 7 | 0UeW24ywj2CMmTtwk_qtm | Nota de prueba Hermes | Document | Contenido de prueba escrito por... | - |
| 8 | b4BEpj6LcOw7h9dtHIH01 | Nueva idea YouTube | Document | Idea inicial: video sobre productividad... | - |
| 9 | UqxfGiUs1cP_aNMvYLEC3 | Prueba plantilla investigacion | Document | Pregunta a responder:Fuentes revisadas... | - |
| 10 | u3eVqOgTmKp0v543KKHm_ | SahaDisk | Document | Rutas de Open-SahaDisk┌─────────────────... | - |
| 11 | SQyRAVo7c- | SahaDisk Rutas y Recompilación | Document | Gestión y Desarrollo de SahaDisk... | - |
| 12 | z32SivYsCe8yl5IsZTFpB | Un dia en la vida de un estudiante de ing sistemas | Document | - | - |
| 13 | 48H-B7QGKGHQz9UdkEbLd | Upsjb | Document | - | - |
| 14 | yaXMip2n5YlwQvphWywo0 | (Sin título) | Document | - | - |
| 15 | l7k7Gg1mqN7cgIBxK29gl | (Sin título) | Document | - | - |
| 16 | Zjj549fr0f823HMyubY6k | (Sin título) | Document | - | - |

### Categorized by Content Type

#### 📚 Technical Documentation
- **SahaDisk** (u3eVqOgTmKp0v543KKHm_)
  - Content: Rutas de Open-SahaDisk + ASCII table
  - Purpose: Technical reference for SahaDisk project
- **SahaDisk Rutas y Recompilación** (SQyRAVo7c-)
  - Content: Gestión y Desarrollo de SahaDisk: guía esencial
  - Purpose: Development workflow documentation

#### 🎬 Content Creation (YouTube/Video)
- **Ideas para videos** (nY2tRTtuRd4GcskFlCIPq)
- **ideas shorts** (AGfRCSBwVSlC-AOgvm1Hv)
  - Content: Primera entrada de ideas para shorts
- **Nueva idea YouTube** (b4BEpj6LcOw7h9dtHIH01)
  - Content: Idea inicial: video sobre productividad. [2026-07-06] Segunda idea: comparar herramientas de productividad

#### 📝 Academic/Study Notes
- **Estatica** (xmRj4MV7w7Am-ReWZuP9Y)
  - Purpose: Study notes for Estática (Static Mechanics)
- **Un dia en la vida de un estudiante de ing sistemas** (z32SivYsCe8yl5IsZTFpB)
- **Upsjb** (48H-B7QGKGHQz9UdkEbLd)

#### 🔬 Research/Investigation
- **Prueba plantilla investigacion** (UqxfGiUs1cP_aNMvYLEC3)
  - Content: Pregunta a responder, Fuentes revisadas, Hallazgos, Conclusión preliminar

#### 🧪 Testing/Pruebas
- **Nota de prueba Hermes** (0UeW24ywj2CMmTtwk_qtm)
  - Content: Contenido de prueba escrito por Playwright
- **2026-07-05** (ObD3rrXgBPgWNl3Zh35xt)

#### 📁 Guides/How-Tos
- **Getting Started** (EQuuWvvi6c)
  - Content: AFFiNE welcome guide
- **How to use folder and Tags** (OELl637r0t)
  - Content: Create folder, and move docs into folders (dragging works as well) Docs can belong to multiple folders Expand info to view and manage tags

#### ❓ Untitled Documents
- yaXMip2n5YlwQvphWywo0
- l7k7Gg1mqN7cgIBxK29gl
- Zjj549fr0f823HMyubY6k

---

## 🔍 Query Commands

### PostgreSQL Queries

#### List All Documents
```bash
docker exec sahacloud-affine-postgres psql -U affine -d affine_db -c "
SELECT 
    page_id,
    COALESCE(title, '(Sin título)') as title,
    COALESCE(summary, '') as summary,
    published_at
FROM workspace_pages 
WHERE workspace_id = '4ace6ac3-7518-41d6-9672-85f08c8eafa1' 
ORDER BY published_at DESC NULLS LAST, title ASC;"
```

#### Count Documents by Type
```bash
docker exec sahacloud-affine-postgres psql -U affine -d affine_db -c "
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
GROUP BY mode;"
```

#### Search for Specific Document
```bash
docker exec sahacloud-affine-postgres psql -U affine -d affine_db -c "
SELECT 
    page_id,
    title,
    summary
FROM workspace_pages 
WHERE workspace_id = '4ace6ac3-7518-41d6-9672-85f08c8eafa1'
  AND LOWER(title) LIKE LOWER('%estática%')
ORDER BY published_at DESC;"
```

#### Get Document Content (Blob)
```bash
docker exec sahacloud-affine-postgres psql -U affine -d affine_db -c "
SELECT 
    b.content
FROM blobs b
JOIN workspace_pages wp ON b.page_id = wp.page_id
WHERE b.workspace_id = '4ace6ac3-7518-41d6-9672-85f08c8eafa1'
  AND wp.title = 'Nueva idea YouTube'
ORDER BY b.created_at DESC 
LIMIT 1;"
```

---

## 🛠️ Browser Automation Commands

### Navigate to AFFiNE
```bash
# Using browser tools
browser_navigate "https://draw.sahacloud.dpdns.org/"

# Wait for page to load
browser_snapshot
```

### List Documents via Browser
```bash
# Click "All docs"
browser_click "@e15"  # ref may vary, check snapshot

# Get document list
browser_snapshot --full true
```

**Note:** Browser automation may miss documents due to:
- Lazy loading (infinite scroll)
- React virtualization
- UI state issues
- **Always verify with PostgreSQL queries for completeness**

---

## ⚠️ Important Notes

### 1. Database vs. Filesystem
- **AFFiNE stores documents in PostgreSQL**, not as files in the filesystem
- The directory `/home/YOUR_USER/.affine/storage/` contains only:
  - Binary blobs (images, attachments)
  - Metadata JSON files
  - **Not** the actual document content in readable format

### 2. Document Content Format
- Document content is stored as **binary JSON** in the `blobs.content` column
- The JSON uses AFFiNE's custom block-based format (Yjs/CRDT)
- To extract readable text, you need to parse this JSON structure

### 3. Browser Limitations
- AFFiNE's web interface uses React and may require JavaScript
- Browser snapshots may not capture all documents due to pagination
- **PostgreSQL queries are the authoritative source** for workspace content

### 4. Time Zone
- Server time: UTC
- Krailynd's local time: UTC-5 (Perú)
- Database timestamps are stored in UTC

### 5. Backup Strategy
```bash
# Backup PostgreSQL database
docker exec sahacloud-affine-postgres pg_dump -U affine affine_db > /tmp/affine_db_backup_$(date +%Y%m%d).sql

# Backup Redis data
docker exec sahacloud-affine-redis redis-cli SAVE

# Backup storage directory
cp -r /home/YOUR_USER/.affine/storage /tmp/affine_storage_backup_$(date +%Y%m%d)
```

---

## 📊 Statistics

| Metric | Value |
|--------|-------|
| Total Documents | 16 |
| Named Documents | 13 |
| Untitled Documents | 3 |
| Document Types | All are mode 0 (standard documents) |
| Workspace Creation | 2026-06-30 |
| Last Known Update | 2026-07-06 |

---

## 🔄 Maintenance

### Health Check
```bash
# Check container status
docker ps --filter "name=sahacloud-affine" --format "table {{.Names}}\t{{.Status}}"

# Check logs
docker logs sahacloud-affine --tail 50

# Check database
docker exec sahacloud-affine-postgres psql -U affine -d affine_db -c "SELECT COUNT(*) FROM workspace_pages WHERE workspace_id = '4ace6ac3-7518-41d6-9672-85f08c8eafa1';"
```

### Restart Stack
```bash
cd ~/sahacloud-infra/stacks/affine
docker compose down && docker compose up -d
```

### Update AFFiNE
```bash
cd ~/sahacloud-infra/stacks/affine
docker compose pull && docker compose up -d --build
```

---

## 🎯 User Preferences (Krailynd)

### Formatting
- **Rejects** disorganized or plain text format for deliverables
- **Prefers** structured tables, organized lists, and professional PDF formatting
- **For AFFiNE notes**: Accepts any format but expects structured content

### Workflow
- Uses AFFiNE as **primary note-taking platform** for personal notes
- Uses **Outline** (`docs.sahacloud.dpdns.org`) for business/agency documentation
- Uses **Nextcloud** (`cloud.sahacloud.dpdns.org`) for file storage
- Uses **AFFiNE** for creative ideas, YouTube planning, and technical notes

### Access Patterns
- Primarily accesses AFFiNE via **WhatsApp** (through Hermes)
- Occasionally uses **web interface** directly
- Expects **complete and accurate** listings when asking "qué notas hay"

---

## 📚 Related References

- **Database Queries:** See `academic-deliverables/references/krailynd_affine_database_queries.md` for comprehensive PostgreSQL queries and examples
- **Hermes Integration:** See `affine/SKILL.md` for Hermes-specific AFFiNE integration commands and workflows