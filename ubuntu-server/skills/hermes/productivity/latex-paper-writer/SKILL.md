---
name: latex-paper-writer
description: Skill de Redacción Agéntica de Documentos Académicos y Libros Masivos (200-300 págs) en LaTeX. Modularización (\include), RAG con NotebookLM, referencias bibliográficas realistas y compilación autónoma a PDF.
---

# Skill de Redacción Agéntica de Documentos Masivos en LaTeX

Skill maestra para la creación, redacción por lotes, verificación de citas y compilación autónoma de libros, tesis y documentos académicos masivos en LaTeX (200+ páginas).

---

## 1. ARQUITECTURA AGÉNTICA POR BLOQUES (CHUNKING & MODULARIZACIÓN)

Para redactar obras extensas sin saturar la ventana de contexto ni alucinar:

### A. Estructura de Proyecto Modular
```
Proyecto_LaTeX/
├── main.tex                 # Archivo maestro de estructura
├── referencias.bib          # Base de datos bibliográfica Zotero / BibTeX
├── capitulos/
│   ├── 01_introduccion.tex
│   ├── 02_marco_teorico.tex
│   └── 03_metodologia.tex
└── figuras/                 # Diagramas PNG HD (Draw/)
```

### B. Archivo Maestro (`main.tex`)
```latex
\documentclass[12pt, a4paper, oneside]{book}
\usepackage[utf8]{inputenc}
\usepackage[spanish]{babel}
\usepackage{amsmath, amsfonts, amssymb}
\usepackage{graphicx}
\usepackage{hyperref}
\usepackage{cite}

\title{Título del Libro o Tesis}
\author{YOUR_NAME "Krailynd"}
\date{\today}

\begin{document}

\frontmatter
\maketitle
\tableofcontents

\mainmatter
\include{capitulos/01_introduccion}
\include{capitulos/02_marco_teorico}

\backmatter
\bibliography{referencias}
\bibliographystyle{plain}

\end{document}
```

---

## 2. REGLAS CONTRA ALUCINACIONES & RAG

1. **Garantía de Fuentes (NotebookLM / RAG)**:
   - Cargar libros y papers base en **Google NotebookLM** vía la skill `/notebooklm`.
   - Regla de oro: *"No inventes datos, fechas, fórmulas ni citas. Si un dato no está explícitamente en el texto de referencia provisto, detén la ejecución y solicita la información"*.
2. **Generación por Lotes Acotados**:
   - Escribir archivo por archivo (`01_introduccion.tex`, etc.) manteniendo el contexto enfocado en esa subsección.
3. **Referencias `.bib` Reales**:
   - Citas etiquetadas como `\cite{autor2026}` vinculadas a registros reales en `referencias.bib`.

---

## 3. COMPILACIÓN AUTÓNOMA Y AUTOCORRECCIÓN (.LOG)

Compilar programáticamente en Ubuntu usando `latex-compiler.py`:

```bash
python3 ~/.local/bin/latex-compiler.py /ruta/proyecto/main.tex --engine pdflatex
```

### Autocorrección de Errores:
- Si la compilación falla, `latex-compiler.py` extrae las líneas del error del archivo `.log`.
- Hermes lee el error de sintaxis TeX (ej. corchete abierto, paquete faltante), corrige únicamente el bloque afectado en el archivo `.tex` correspondiente y reintenta la compilación autónoma.

---

## 4. INTEGRACIÓN CON OBSIDIAN VAULT (`E:\YOUR_VAULT\`)

Hermes guardará las copias del proyecto LaTeX y los PDFs compilados en tu Vault:
- `E:\YOUR_VAULT\Documentos\LaTeX_Projects\`
- `E:\YOUR_VAULT\Draw\` (Diagramas incrustados `\includegraphics{figuras/diagrama.png}`)
