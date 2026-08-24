---
name: krailynd-google-workspace
description: "Quick Calendar/Drive/Sheets/Docs via google-workspace."
version: 1.0.0
author: krailynd
license: MIT
platforms: [linux, macos, windows]
dependencies:
  - productivity/google-workspace
metadata:
  hermes:
    tags: [google, calendar, drive, sheets, docs, krailynd]
    related_skills: [productivity/google-workspace]
---

# krailynd-google-workspace

Wrapper cómodo para operaciones habituales de Google Workspace (Calendar, Drive, Sheets, Docs) usando la skill base `google-workspace` ya autenticada.

## Scripts disponibles

- `scripts/calendar.py` — Eventos de calendario (listar, crear, próximas 24h, semana)
- `scripts/drive.py` — Archivos Drive (buscar, subir, descargar, compartir)
- `scripts/sheets.py` — Hojas de cálculo (crear, leer, escribir, append)
- `scripts/docs.py` — Documentos (crear, leer, append)
- `scripts/common.py` — Helpers compartidos

## Uso rápido

```bash
GAPI="python ~/.hermes/skills/productivity/google-workspace/scripts/google_api.py"
KGAPI="python ~/.hermes/skills/productivity/krailynd-google-workspace/scripts/calendar.py"
```

## Comandos principales

### Calendar
```bash
# Próximos eventos (24h)
python ~/.hermes/skills/productivity/krailynd-google-workspace/scripts/calendar.py next

# Esta semana
python ~/.hermes/skills/productivity/krailynd-google-workspace/scripts/calendar.py week

# Crear evento
python ~/.hermes/skills/productivity/krailynd-google-workspace/scripts/calendar.py create "Título" "2026-08-22T10:00:00-05:00" "2026-08-22T11:00:00-05:00"

# Listar calendarios
python ~/.hermes/skills/productivity/krailynd-google-workspace/scripts/calendar.py calendars
```

### Drive
```bash
# Buscar archivos
python ~/.hermes/skills/productivity/krailynd-google-workspace/scripts/drive.py search "informe"

# Subir archivo
python ~/.hermes/skills/productivity/krailynd-google-workspace/scripts/drive.py upload /ruta/archivo.pdf

# Compartir
python ~/.hermes/skills/productivity/krailynd-google-workspace/scripts/drive.py share FILE_ID --email usuario@ejemplo.com --role reader
```

### Sheets
```bash
# Crear spreadsheet
python ~/.hermes/skills/productivity/krailynd-google-workspace/scripts/sheets.py create "Mi Hoja"

# Leer rango
python ~/.hermes/skills/productivity/krailynd-google-workspace/scripts/sheets.py get SHEET_ID "Hoja1!A1:D10"

# Escribir rango
python ~/.hermes/skills/productivity/krailynd-google-workspace/scripts/sheets.py update SHEET_ID "Hoja1!A1" --values '[["A","B"],["1","2"]]'

# Append filas
python ~/.hermes/skills/productivity/krailynd-google-workspace/scripts/sheets.py append SHEET_ID "Hoja1!A:C" --values '[["nueva","fila","data"]]'
```

### Docs
```bash
# Crear doc
python ~/.hermes/skills/productivity/krailynd-google-workspace/scripts/docs.py create "Título del doc"

# Leer doc
python ~/.hermes/skills/productivity/krailynd-google-workspace/scripts/docs.py get DOC_ID

# Append texto
python ~/.hermes/skills/productivity/krailynd-google-workspace/scripts/docs.py append DOC_ID "Texto a añadir"
```

## Zona horaria

Por defecto usa `America/Lima` (UTC-5). Cambia con `--tz` en comandos calendar.

## Requisitos

- Skill `google-workspace` configurada y autenticada (`setup.py --check` → AUTHENTICATED)
- Token en `~/.hermes/google_token.json` (compartido)