---
name: obsidian-second-brain
description: Sistema maestro del Segundo Cerebro para Obsidian (E:\YOUR_VAULT\ en Windows), NotebookLM MCP y Hermes vía SSH Tailscale. Integración de notas, Podcasts de Audio, Guías de Estudio, Diagramas 1080p y Tablas Dataview.
---

# Obsidian Second Brain & Google NotebookLM Master Skill

Skill maestra que unifica tu Vault de Obsidian (`E:\YOUR_VAULT\` en Windows), Google NotebookLM (vía MCP) y Hermes.

---

## 1. ARQUITECTURA Y ACCESO NATIVO

- **Ruta del Vault en Windows**: `E:\YOUR_VAULT\` (Host `windows-krai`).
- **Herramienta Ejecutable**: `obsidian-win-ssh` (`~/.local/bin/obsidian-win-ssh`).
- **Servidor MCP NotebookLM**: Activado en Hermes (`notebooklm-mcp-server`).
- **Conexión SSH sobre Tailscale**: IP `YOUR_TAILSCALE_IP` (Base64 UTF-8).

---

## 2. FLUJO INTELIGENTE: OBSIDIAN + NOTEBOOKLM

Cuando le pides a Hermes crear un material de estudio, podcast, mapa mental o resumen:

```
1. Leer / Crear Nota en Obsidian (E:\YOUR_VAULT\Documentos\)
   └─ obsidian-win-ssh write "Documentos/Tema.md" --content "..."

2. Enviar Nota a NotebookLM vía MCP
   ├─ notebook_create "Tema de Estudio"
   └─ notebook_add_text (Contenido de la Nota de Obsidian)

3. Generar Entregables Inteligentes con NotebookLM MCP:
   ├─ audio_overview_create  -> Genera el Podcast de Audio (dos locutores discutiendo el tema)
   ├─ mind_map_generate      -> Genera el Mapa Mental
   └─ get_study_guide        -> Genera la Guía de Examen + Preguntas + FAQs

4. Guardar Entregables de Vuelta en Obsidian:
   ├─ Texto / Guía de Estudio -> E:\YOUR_VAULT\Documentos\Guia_Tema.md
   └─ Diagramas HD 1080p       -> E:\YOUR_VAULT\Draw\diag.png (vía local-diagram.py)
```

---

## 3. PASO DE AUTENTICACIÓN INICIAL DE NOTEBOOKLM (SOLO 1 VEZ)

Para conectar tu cuenta de Google con el servidor MCP de NotebookLM en Hermes, ejecuta en la terminal:

```bash
npx -y notebooklm-mcp-server auth
```

*Inicias sesión en tu cuenta de Google y la sesión quedará guardada de forma segura para siempre.*

---

## 4. GUÍA DE ELEMENTOS OBSIDIAN PARA HERMES

### A. Plantilla Oficial de Nota con YAML
```markdown
---
title: "Título del Tema"
date: YYYY-MM-DD
tags: [estudio, notebooklm, java, ia]
status: activo
notebooklm_sync: true
---

# Título del Tema

> [!INFO] Resumen Ejecutivo
> Explicación rápida del tema.

## Guía de Estudio / FAQs (Generada por NotebookLM)
> [!QUESTION] ¿Pregunta de Examen 1?
> Respuesta fundada en el material de estudio.

## Diagrama Nocional (1080p HD)
![[Draw/diagrama_tema.png]]

## Código / Ejemplos Prácticos
```python
# Ejemplo relevante
```
```

### B. Callouts de Obsidian
- `> [!NOTE]` -> Resúmenes o notas generales.
- `> [!WARNING]` -> Puntos donde se suele fallar en exámenes.
- `> [!TIP]` -> Atajos y tips de estudio.
- `> [!QUESTION]` -> Preguntas prácticas de evaluación.

---

## 5. COMANDOS ÚTILES PARA HERMES

- **Escribir Nota en Windows**:
  ```bash
  obsidian-win-ssh write "Documentos/MiTema.md" --content "..."
  ```
- **Leer Nota de Windows**:
  ```bash
  obsidian-win-ssh read "Documentos/MiTema.md"
  ```
- **Generar Diagrama 1080p y Enviar a Draw/**:
  ```bash
  python3 ~/.local/bin/local-diagram.py --code "graph TD; A-->B" --out /tmp/d.png
  scp -q -o RemoteCommand=none -o RequestTTY=no /tmp/d.png windows-krai:E:\YOUR_VAULT\Draw\d.png
  ```
