---
name: hsade-engine
description: Hermes Scientific Animation & Document Engine (HSADE). Integración nativa de ManimCE 0.20.1, compilador LaTeX autónomo (200-300 págs), diagramas de ingeniería (UML 2.5/BPMN 2.0) y fuentes científicas verificadas.
---

# HSADE — Hermes Scientific Animation & Document Engine

Skill maestra para entregables científicos, académicos y tecnológicos de nivel profesional.

---

## 1. COMPONENTES DEL MOTOR (EJECUCIÓN NATIVA)

- **ManimCE v0.20.1**: Animaciones 2D/3D al estilo 3Blue1Brown (`~/.local/bin/manim`).
- **Compilador LaTeX Autónomo**: `latex-compiler.py` (`pdflatex`) con autocorrección de errores del `.log` y soporte para libros masivos (200+ páginas). Formato APA 7ª estricto en negro (sin títulos azules ni distorsiones visuales).
- **Lector Web Universal (v2.0)**: `web-reader.py` con caché SQLite local (`~/.cache/hermes_web_cache.db`) y renderizado Playwright Chrome.
- **Búsqueda Académica Verificada**: Scopus, Web of Science, PubMed, SciELO, Redalyc, Dialnet, ArXiv, Alicia-Concytec, Renati-Sunedu.
- **Entrega de Archivos**: Copia inmediata a `SahaCloud/ACCESOS_RAPIDOS/` y envío al chat vía `hermes_send_file.sh`.
