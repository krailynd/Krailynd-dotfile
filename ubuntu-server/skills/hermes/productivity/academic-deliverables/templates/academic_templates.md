# Template: Academic Problem Solution (Markdown)

---
**Template Type:** Academic Problem Solution
**Format:** Markdown
**Use Case:** Solving mathematical, physics, engineering problems
**Delivery:** Send as .md file via WhatsApp for problems > 1500 chars
---

```markdown
# [Topic]: [Problem Description]

**Fecha:** [Date]
**Tipo:** [Problem Type - e.g., Derivada, Integral, Ecuación Diferencial]

## Problema

[Complete problem statement]

## Solución

### 1. Explicación Breve
[1-2 sentences summarizing the approach and result]

### 2. Desarrollo Completo

#### Paso 1: [Step Description]
[Detailed explanation with formulas]

[Equation in LaTeX format: $...$ or $$...$$]

#### Paso 2: [Step Description]
[Continue with next step]

[Apply theorem/rule: e.g., "Por el Teorema Fundamental del Cálculo..." ]

#### ...

### 3. Solución Final

[Final answer in boxed format]

> **Respuesta:** \boxed{[Final Answer]}

## Verificación

[Optional: Verification of the solution]

## Referencias
- [Author]. (Year). *Title*. Publisher.
- [Additional references in APA 7 format]
```

---

# Template: Academic Problem Solution (LaTeX)

---
**Template Type:** Academic Problem Solution
**Format:** LaTeX
**Use Case:** Formal mathematical solutions, research-quality documents
**Delivery:** Send as .tex file with compilation instructions
---

```latex
% Compile: pdflatex filename.tex
% Or: latexmk -pdf filename.tex
\documentclass[12pt]{article}
\usepackage[spanish]{babel}
\usepackage[utf8]{inputenc}
\usepackage{amsmath}
\usepackage{amsfonts}
\usepackage{amssymb}
\usepackage{geometry}
\geometry{a4paper, margin=1in}
\usepackage{fancyhdr}
\usepackage{tcolorbox}
\usepackage{hyperref}

\title{[Topic]: [Problem Description]}
\author{Hermes - Asistente Académico}
\date{\today}

\begin{document}

\maketitle

\section*{Problema}
[Problem statement in LaTeX format]

\section*{Solución}

\subsection*{1. Explicación Breve}
[Brief explanation]

\subsection*{2. Desarrollo Completo}

\subsubsection*{Paso 1: [Step Description]}
\begin{equation*}
    [Equation]
\end{equation*}

Explicación: [Detailed explanation]

\subsubsection*{Paso 2: [Step Description]}
\begin{align*}
    [Multi-line derivation]
\end{align*}

\begin{tcolorbox}[colback=blue!5!white, colframe=blue!75!black, title=Teorema Aplicado]
[Theorem name and statement]
\end{tcolorbox}

\section*{Solución Final}

\begin{center}
\begin{LARGE}
\textbf{SOLUCIÓN FINAL: } \boxed{[Final Answer]}
\end{LARGE}
\end{center}

\section*{Referencias}
\begin{itemize}
    \item [Author]. (Year). \textit{Title}. Publisher.
\end{itemize}

\end{document}
```

---

# Template: Study Guide (Markdown)

---
**Template Type:** Study Guide
**Format:** Markdown
**Use Case:** Summary of concepts, exam preparation
---

```markdown
# Guía de Estudio: [Topic]

**Fecha:** [Date]
**Asignatura:** [Subject]

## 📚 Conceptos Clave

- **Concepto 1:** [Definition]
- **Concepto 2:** [Definition]
- **Fórmula 1:** [Formula in LaTeX: $...$]
- **Fórmula 2:** [Formula in LaTeX: $...$]

## 🧮 Problemas Resueltos

### Problema 1: [Description]
**Solución:** [Brief solution]
**Respuesta:** \boxed{[Answer]}

### Problema 2: [Description]
**Solución:** [Brief solution]
**Respuesta:** \boxed{[Answer]}

## ⚠️ Errores Comunes

1. **Error 1:** [Description and how to avoid]
2. **Error 2:** [Description and how to avoid]

## 💡 Consejos para el Examen

- [Tip 1]
- [Tip 2]
- [Tip 3]

## 📝 Preguntas de Repaso

1. [Question 1]
2. [Question 2]
3. [Question 3]
```

---

# Template: Formula Sheet (Markdown)

---
**Template Type:** Formula Sheet
**Format:** Markdown
**Use Case:** Compact reference of formulas for exams
---

```markdown
# Formulario: [Topic]

**Fecha:** [Date]

## [Category 1]

| Símbolo | Fórmula | Descripción |
|---------|---------|-------------|
| [Symbol] | $ [Formula] $ | [Description] |
| [Symbol] | $ [Formula] $ | [Description] |

## [Category 2]

- $ [Formula 1] $ — [Description]
- $ [Formula 2] $ — [Description]

## Constantes

- $ [Constant 1] = [Value] $ — [Description]
- $ [Constant 2] = [Value] $ — [Description]
```

---

# Compilation Instructions for Users

## If You Have LaTeX Installed

```bash
# Single compilation
pdflatex your_file.tex

# Better: Use latexmk (handles multiple compilations)
latexmk -pdf your_file.tex

# Clean up auxiliary files
latexmk -c your_file.tex
```

## If You Don't Have LaTeX Installed

### Option 1: Overleaf (Recommended)
1. Go to https://www.overleaf.com/
2. Create a new project
3. Copy the LaTeX code
4. Compile and download PDF

### Option 2: Online Compilers
- https://www.papeeria.com/
- https://texlive.net/
- https://www.sharelatex.com/

### Option 3: Local Installation

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install texlive texlive-latex-extra texlive-fonts-recommended
```

**Mac:**
```bash
# Using MacTeX
# Download from https://www.tug.org/mactex/
```

**Windows:**
```bash
# Download MikTeX from https://miktex.org/
# Or TeX Live from https://www.tug.org/texlive/
```
