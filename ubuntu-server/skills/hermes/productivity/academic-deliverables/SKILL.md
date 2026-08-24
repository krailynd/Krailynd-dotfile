---
name: academic-deliverables
description: "Generate academic deliverables (reports, solved problems, study guides, LaTeX, PDF) with proper formatting and delivery via WhatsApp."
version: 1.0.0
author: Hermes Agent
tags: [academic, reports, latex, pdf, education, whatsapp, delivery, formatting]
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [academic, reports, latex, pdf, education, whatsapp, delivery, formatting]
---

# Academic Deliverables

This skill governs the generation, formatting, and delivery of academic content for students and researchers. It covers mathematical proofs, problem solutions, study guides, reports, and formatted deliverables in LaTeX, PDF, and Markdown formats.

## When to Use

Load this skill whenever the user requests:
- Academic problem solving (math, physics, engineering, etc.)
- Generation of study materials (guías, apuntes, formularios)
- LaTeX document creation
- PDF report generation
- Delivery of academic content via WhatsApp
- Any request involving mathematical notation or formal academic formatting

## Core Principles

### Academic Rigor
- **Always show all steps** — never skip derivations with "it can be shown that" or "clearly"
- **Name every theorem/rule** — explicitly state which theorem, identity, or rule is being applied at each step
- **Use proper notation** — mathematical notation must use LaTeX format: `$...$` for inline, `$$...$$` for block equations
- **Classify problems first** — for differential equations, state ODE/PDE, order, linearity, homogeneity before solving

### Delivery Standards
- **WhatsApp constraints**: Responses > 1500 characters must be sent as files
- **Code formatting**: Code > 20 lines must be sent as files (.py, .sh, etc.)
- **Diagrams**: Use `generate_diagram.py` for Mermaid/Graphviz → PNG → send as image
- **Projects**: Multi-file deliverables must be ZIP compressed
- **LaTeX**: Always generate complete .tex files with preamble, not fragments

## File Structure for Academic Deliverables

### Single File Deliverables
```
/tmp/hermes_[topic]_[type].[ext]
Examples:
- /tmp/hermes_derivada_exponencial.md
- /tmp/hermes_calculo_integral.tex
- /tmp/hermes_fisica_problema.pdf
```

### Multi-File Projects
```
/tmp/hermes_[projectname]/
  ├── main.tex (or main.md)
  ├── diagrams/
  │   └── figure1.png
  ├── code/
  │   └── solution.py
  └── README.md
Then: hermes_zip_send.sh /tmp/hermes_[projectname] PHONE "caption"
```

## Academic Content Types

### 1. Problemas Resueltos (Solved Problems)
**Structure:**
- Problem statement
- Method/theorem identification
- Step-by-step solution with justifications
- Final answer highlighted in box
- Alternate method if applicable

**Format:** Markdown or LaTeX

**Example:**
```markdown
#### Problema 1: Derivada de f(x) = a^x
**Enunciado:** Hallar la derivada de f(x) = a^x

**Método:** Derivada de función exponencial

**Solución:**
1. Usamos la definición de derivada: f'(x) = lim(h→0) [f(x+h) - f(x)]/h
2. Sustituimos: f'(x) = lim(h→0) [a^(x+h) - a^x]/h
3. Factorizamos: f'(x) = a^x · lim(h→0) [a^h - 1]/h
4. Aplicamos límite fundamental: lim(h→0) [a^h - 1]/h = ln(a)
5. Resultado: f'(x) = a^x · ln(a)

**Respuesta Final:** 
\boxed{f'(x) = a^x \ln(a)}
```

### 2. Apuntes (Class Notes)
**Structure:**
- Topic header
- Definitions
- Theorems or key rules
- Worked examples
- Summary

**Format:** Markdown (preferred) or LaTeX (for math-heavy)

### 3. Formularios (Formula Sheets)
**Structure:**
- Compact reference only (no prose)
- One formula per line
- Grouped by category
- Units included for engineering formulas

**Format:** Markdown or LaTeX

### 4. Guías de Estudio (Study Guides)
**Structure:**
- Key concepts list
- Review questions (conceptual and numerical)
- Common mistakes
- Exam tips

**Format:** Markdown

### 5. Reportes Técnicos (Technical Reports)
**Structure:**
- Title, abstract
- Introduction
- Sections with numbering
- Conclusion
- References (APA 7 format by default)

**Format:** Markdown with LaTeX for equations

## LaTeX Generation

### Complete Document Structure
Every LaTeX file must be complete and compilable:

```latex
% Compile: pdflatex filename.tex
% o: latexmk -pdf filename.tex
\documentclass[12pt]{article}
\usepackage[spanish]{babel}
\usepackage[utf8]{inputenc}
\usepackage{amsmath}
\usepackage{amsfonts}
\usepackage{amssymb}
\usepackage{geometry}
\geometry{a4paper, margin=1in}
\usepackage{graphicx}
\usepackage{fancyhdr}
\usepackage{tcolorbox}
\usepackage{hyperref}

\title{Title}
\author{Author}
\date{\today}

\begin{document}

\maketitle

\section*{Problema}
... content ...

\section*{Solución}
... solution ...

\end{document}
```

### Required Packages by Subject

| Subject | Required Packages |
|---------|-------------------|
| Mathematics | amsmath, amssymb, geometry |
| Engineering | siunitx, circuitikz (for circuits) |
| Physics | physics, amsmath |
| Chemsitry | chemfig, mhchem |
| General | hyperref, graphicx, fancyhdr |

### Compile Instructions
Always include in header comment:
```
% Compile: pdflatex filename.tex
% Or: latexmk -pdf filename.tex
```

## PDF Generation

### Using ReportLab (Python)
For simple PDFs without LaTeX compilation:

```python
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter

c = canvas.Canvas("/tmp/output.pdf", pagesize=letter)
c.setFont("Helvetica", 12)
c.drawString(1*inch, 10*inch, "Hello World")
c.save()
```

### Using LaTeX (Preferred for Math)
1. Generate .tex file with complete document
2. Compile with pdflatex or latexmk
3. If compilation fails, send .tex file with instructions

## WhatsApp Delivery

### Delivery Rules (Absolute)
- **Text > 1500 chars**: Send as file + short summary inline
- **Code > 20 lines**: Send as file (.py, .sh, etc.)
- **Projects (3+ files)**: ZIP and send
- **Diagrams**: PNG via generate_diagram.py → send as image
- **LaTeX**: Send .tex file (compile if pdflatex available)
- **PDF**: Send as document

### Delivery Commands

```bash
# Send single file
~/.hermes/scripts/hermes_send_file.sh /path/to/file document PHONE "caption"

# Send image
~/.hermes/scripts/hermes_send_file.sh /path/to/image.png image PHONE "caption"

# Send ZIP
~/.hermes/scripts/hermes_zip_send.sh /path/to/directory PHONE "caption"
```

### Priority Order for Multiple Files
When multiple files need to be sent but WhatsApp may have limits:
1. **PDF** (highest priority - ready to view)
2. **ZIP** (complete project)
3. **LaTeX source** (for compilation)
4. **Individual files** (lowest priority)

## Common Academic Tasks

### Mathematical Proofs
1. State what is to be proved
2. List assumptions/conditions
3. Apply reasoning with explicit justifications
4. Close with QED or equivalent

### Derivatives and Integrals
- Always show the rule/theorem being applied
- Include intermediate steps
- State domain restrictions

### Differential Equations
1. Classify: ODE/PDE, order, linear/nonlinear, homogeneous/non-homogeneous
2. Select appropriate method
3. Apply method with all steps shown
4. Verify solution if possible

### Physics Problems
- Draw free body diagrams (ASCII or Mermaid)
- State known and unknown quantities
- Apply relevant laws with units
- Check dimensional consistency

## Quality Standards

### For All Academic Content
- **Accuracy**: Double-check all calculations and derivations
- **Clarity**: Explain concepts in understandable terms
- **Completeness**: Include all necessary steps and justifications
- **Formatting**: Use proper mathematical notation

### For Deliverables
- **File naming**: Use descriptive names (hermes_[topic]_[type].[ext])
- **Organization**: Multi-file projects must have clear structure
- **Documentation**: Include README or header comments
- **Compilability**: LaTeX must compile (if possible) or include compilation instructions

## Pitfalls and Common Mistakes

### ❌ Don't Do
- Skip steps in derivations
- Use informal notation for serious math
- Send large text blocks inline on WhatsApp
- Assume user has LaTeX compiler installed
- Forget to include units in engineering problems
- Use "obviously" or "clearly" without justification
- **For comprehensive research requests**: When user asks for detailed, multi-section research (e.g., F1 engineering roles, academic paths, technical projects), generate a complete structured report in Markdown with proper headers, tables, bullet points, and verified sources. Deliver as PDF or MD file with professional formatting.
- **For WhatsApp reminders with audio**: Use TTS (edge-tts with es-PE-AlexNeural voice) for Spanish audio messages. Schedule via cronjob with `deliver: whatsapp` and include the TTS generation command in the prompt.
- **F1 Engineering Research**: For Krailynd's F1 career research, always include: (1) Role definitions with current responsibilities, (2) Real professionals with LinkedIn profiles when available, (3) Salary ranges in GBP/USD by experience level, (4) Academic paths with Peru universities and international options, (5) Technical projects with FastF1 and other tools, (6) Local motorsport opportunities in Peru.
- **For WhatsApp reminders with audio**: Use TTS (edge-tts with es-PE-AlexNeural voice) for Spanish audio messages. Schedule via cronjob with `deliver: whatsapp` and include the TTS generation command in the prompt.

### ✅ Do Instead
- Show every step explicitly
- Use proper LaTeX notation
- Send as files when content is long
- Provide compilation instructions
- Always include units
- Justify every non-trivial step
- **For Krailynd: Check AFFiNE web interface first when asked about "apuntes" or notes**
- **For Krailynd: Always use professional formatting with tables, headers, and clear structure**

### Krailynd-Specific Note Locations
- **AFFiNE**: `draw.sahacloud.dpdns.org` (primary note-taking platform, self-hosted)
 - Notes are stored in AFFiNE's database (PostgreSQL), **not** as `.md` files in the local filesystem
 - Local storage at `/home/sahacloud/.affine/storage/` contains only blobs (images, SVG, metadata)
 - **Never search for `.md` files in `.affine/storage/`** — this will not yield readable notes
 - **To query AFFiNE notes**: Use PostgreSQL queries against `affine_db` (container: `sahacloud-affine-postgres`)
 - Pages: `workspace_pages` table (workspace_id: `4ace6ac3-7518-41d6-9672-85f08c8eafa1`)
 - Blobs: `blobs` table (contains document content as JSON)
 - Snapshots: `snapshots` table (historical versions)
 - **Web access**: Use browser tools to navigate `draw.sahacloud.dpdns.org` for visual inspection
 - **Cron jobs for reminders**: Use `cronjob` tool with `deliver: whatsapp` to schedule WhatsApp messages. **IMPORTANT**: The `deliver` parameter must be explicitly set to `whatsapp` for WhatsApp delivery. Omitting it or using `origin` may default to other channels. Test with short schedules (1-2 minutes) to verify delivery before relying on longer-term reminders.
- **Nextcloud**: `cloud.sahacloud.dpdns.org` (file storage, may contain exported notes)
- **Outline**: `docs.sahacloud.dpdns.org` (documentation, SOPs, wikis for Sahahacking)
- **Local files**: `/home/sahacloud/SahaCloud/` (Windows-visible, vboxsf mount, for project files)

### Audio Transcription Capabilities
- **STT (Speech-to-Text)**: Local faster-whisper model available for Spanish transcription
- **Supported formats**: OGG, MP3, M4A, WAV
- **Command**: `python3 ~/.hermes/scripts/hermes_transcribe.py /path/to/audio.ogg --language es`
- **Model options**: `base` (fast, default), `small` (more accurate), `medium` (most accurate, slower)
- **Krailynd's preference**: Uses Spanish (es) language for transcription
- **Audio cache location**: `/home/sahacloud/.hermes/cache/audio/` (received WhatsApp audios stored here)

### Debugging Note Locations for Krailynd
When Krailynd asks about notes/apuntes:
1. **First**: Ask if they are in AFFiNE (most likely for personal notes)
2. **Second**: Check Outline (for business/agency documentation)
3. **Third**: Check Nextcloud (for file-based notes)
4. **Last**: Search local filesystem (unlikely for notes, more likely for configs)

## WhatsApp-Specific Considerations

### Character Limits
- Single message: ~1500 characters
- Use bullet points for lists
- Use numbered lists only when sequence matters

### Formatting
- **Bold**: Use `**text**` or `_text_` (WhatsApp converts to native formatting)
- **Italic**: Use `*text*`
- **Code**: Use backticks: `` `code` ``
- **Strikethrough**: Use `~~text~~`

### Math Notation
- For simple math: Use plain text (e.g., `f'(x) = 2x`)
- For complex math: Send as LaTeX file or rendered PNG
- For diagrams: Generate PNG and send as image

## Example Workflow: Solving a Calculus Problem

**User Request:** "Resolve: La derivada de f(x) = a^x es xa^(x-1). ¿Verdadero o Falso?"

**Steps:**
1. Analyze the problem: Function is exponential, not power
2. Recall derivative rule: d/dx[a^x] = a^x·ln(a)
3. Compare with given: xa^(x-1) is power rule, not exponential
4. Generate content:
   - Brief explanation: FALSO
   - Complete development with all steps
   - Final answer in box
5. Create files:
   - Markdown: /tmp/hermes_derivada_exponencial.md
   - LaTeX: /tmp/hermes_derivada_exponencial.tex
   - PDF: /tmp/hermes_derivada_exponencial.pdf (if compilation available)
   - ZIP: /tmp/hermes_derivada_exponencial.zip (all files)
6. Deliver:
   - Send PDF first (highest priority)
   - Send ZIP with all files
   - Send brief summary inline

## Tools Integration

### Diagram Generation
```bash
# Generate diagram and send to WhatsApp
python3 ~/.hermes/scripts/generate_diagram.py "DIAGRAM_SOURCE" \
  --type mermaid \
  --whatsapp PHONE \
  --caption "description"

# Generate to file only
python3 ~/.hermes/scripts/generate_diagram.py "DIAGRAM_SOURCE" \
  --type mermaid \
  --format png \
  --output /tmp/diagram.png
```

- **Templates:** See `templates/academic_templates.md` for Markdown and LaTeX templates
- **Templates:** See `templates/landing_page_template.html` for reusable landing page structure (Krailynd's SahaNotes template)
- **Templates:** See `templates/safeschool_uv_project_template.md` for complete SafeSchool-UV project structure
- **Templates:** See `templates/hackathon_minedu_proposal.md` for standardized MINEDU Hackathon proposal format (Krailynd-specific)
- **Scripts:** See `scripts/whatsapp_delivery.py` for delivery utilities
- **Scripts:** See `scripts/landing_page_generator.js` for programmatic landing page generation (Node.js)
- **References:** See `references/hackathon_minedu_2026_competitive_intelligence.md` for MINEDU Hackathon historical analysis, winning patterns, and Krailynd-specific recommendations
- **References:** See `references/krailynd_hackathon_workflow.md` for Krailynd-specific Hackathon preferences, workflow, and best practices
- **References:** See `references/krailynd_whatsapp_reminders.md` for WhatsApp reminder configuration, time zone handling (Peru UTC-5), and debugging steps
- **References:** See `references/audio_transcription_workflow.md` for complete audio transcription workflow, commands, and Krailynd-specific usage patterns
- **References:** See `references/krailynd_affine_database_queries.md` for complete PostgreSQL queries, table structure, and Krailynd's AFFiNE workspace documentation
- **References:** See `references/reportlab_pdf_extraction.md` for handling ReportLab-generated PDFs (text extraction from Hermes-generated documents)

### File Delivery
```bash
# Send file via WhatsApp
~/.hermes/scripts/hermes_send_file.sh /tmp/file.pdf document YOUR_WHATSAPP_NUMBER "caption"

# Send ZIP
~/.hermes/scripts/hermes_zip_send.sh /tmp/project_dir PHONE "caption"
```

### LaTeX Compilation
```bash
# If pdflatex available
pdflatex /tmp/file.tex

# If not, use latexmk
latexmk -pdf /tmp/file.tex

# If neither available, send .tex with instructions
```

## References

### Mathematical Notation
- Use `amsmath` package for equations
- Use `align*` for multi-line derivations
- Use `equation` for single equations
- Use `cases` for piecewise functions

### Citation Format
- Default: APA 7
- Can be changed per user request

### Language
- Respond in user's language
- Spanish: Use "Solución Final" for final answer
- English: Use "Final Answer" for final answer
