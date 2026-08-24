---
name: estudio-examen
description: Skill de Modo Estudio Examen: Convierte PDFs, vídeos de YouTube o notas en guías de estudio, simulacros de examen, diagramas y audio-podcasts de NotebookLM en el Vault de Obsidian.
---

# Skill Modo Estudio Examen (Obsidian + NotebookLM)

Skill especialista para transformar cualquier material académico (PDFs, vídeos de YouTube, papers, notas) en **Simulacros de Examen, Guías de Estudio, Diagramas y Podcasts de Audio de NotebookLM** guardados en tu Vault de Obsidian (`E:\YOUR_VAULT\`).

---

## 1. FLUJO DE TRABAJO AUTOMATIZADO

```
1. ENTRADA DE MATERIAL
   ├─ Archivo PDF / Documento local
   ├─ Enlace de YouTube / Artículo Web
   └─ Nota existente en Obsidian (E:\YOUR_VAULT\)

2. PROCESAMIENTO CON NOTEBOOKLM (MCP)
   ├─ notebook_create "Asignatura - Tema"
   ├─ notebook_add_text / notebook_add_url / notebook_add_local_file
   ├─ audio_overview_create  -> Genera el Podcast de Audio de Estudio
   └─ get_study_guide        -> Extrae FAQs, Términos Clave y Preguntas de Examen

3. GENERACIÓN DE DIAGRAMAS HD (1080p)
   └─ local-diagram.py -> Genera mapa conceptual en E:\YOUR_VAULT\Draw\

4. SALIDA Y REGISTRO EN OBSIDIAN (E:\YOUR_VAULT\)
   ├─ Documentos/Estudio_Tema.md (Guía + Simulacro de Examen + Callouts)
   └─ Notificación y resumen entregado al Chat (WhatsApp/Telegram/Dashboard)
```

---

## 2. PLANTILLA OFICIAL DE NOTA DE ESTUDIO EN OBSIDIAN

Toda guía de examen creada en `E:\YOUR_VAULT\Documentos\` incluirá el formato:

```markdown
---
title: "Guía de Examen: [Nombre del Tema]"
date: YYYY-MM-DD
tags: [estudio, examen, universidad, notebooklm]
status: activo
notebooklm_sync: true
---

# 📚 Guía de Estudio y Simulacro de Examen: [Tema]

> [!INFO] Resumen de Conceptos Clave
> Síntesis ejecutiva de los puntos con mayor probabilidad de entrar en el examen.

---

## 🗺️ Mapa Conceptual
![[Draw/diagrama_estudio.png]]

---

## 📝 Simulacro de Examen (Preguntas & Respuestas)

> [!QUESTION] Pregunta 1: [Concepto Crítico]
> **Opción A)** ...
> **Opción B)** ...
> **Opción C)** ...
>
> > [!SUCCESS] Respuesta Correcta & Explicación
> > **Respuesta B**: Explicación detallada fundada en las fuentes.

> [!QUESTION] Pregunta 2: [Pregunta de Desarrollo]
> **Consigna**: Explicar la diferencia entre X e Y.
>
> > [!TIP] Solución Modelo
> > Puntos esenciales que debe incluir la respuesta para puntaje máximo.

---

## 📊 Tabla de Términos y Fórmulas
| Término / Fórmula | Explicación / Definición | Aplicación Práctica |
|---|---|---|
| Concepto A | Definición precisa | Caso de uso en examen |
```

---

## 3. COMANDOS ÚTILES PARA HERMES

- **Escribir Guía de Estudio en Obsidian**:
  ```bash
  obsidian-win-ssh write "Documentos/Guia_Estudio_Tema.md" --content "..."
  ```
- **Generar Diagrama HD de Estudio**:
  ```bash
  python3 ~/.local/bin/local-diagram.py --code "graph TD; A[Concepto]-->B[Aplicación];" --out /tmp/diag_estudio.png
  scp -q -o RemoteCommand=none -o RequestTTY=no /tmp/diag_estudio.png windows-krai:E:\YOUR_VAULT\Draw\diag_estudio.png
  ```
