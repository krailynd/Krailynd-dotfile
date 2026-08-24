# Krailynd - Preferencias y Requisitos para LaTeX

## Contexto
Krailynd (YOUR_NAME) tiene requisitos específicos para documentos LaTeX, especialmente en el contexto académico y de Hackathons (ej: MINEDU 2026). Este documento consolida sus preferencias, errores comunes a evitar, y patrones de trabajo validados.

---

## 📌 Requisitos Generales para Documentos LaTeX

### 1. Estructura Obligatoria
**TODO documento LaTeX debe incluir:**
```latex
% Compile: pdflatex FILENAME.tex | latexmk -pdf FILENAME.tex
\documentclass[12pt,a4paper]{article}
\usepackage[T1]{fontenc}
\usepackage[utf8]{inputenc}
\usepackage[spanish]{babel}
% --- Paquetes adicionales según necesidad ---
```

**Reglas absolutas:**
- **Primera línea:** SIEMPRE `\documentclass{...}` (sin texto ni comentarios antes).
- **Preámbulo:** Solo paquetes y configuración técnica (nada de contenido visible).
- **Contenido:** TODO dentro de `\begin{document}...\end{document}`.
- **No mezclar plantillas** distintas en el mismo archivo.

---

## 🚫 Errores Comunes y Cómo Evitarlos

### 1. Problemas de Encoding (Caracteres Especiales)
**Error:**
```
LaTeX Error: Unicode character ó (U+00F3) not set up for use with LaTeX.
```

**Solución:**
- Usar **siempre** en el preámbulo:
  ```latex
  \usepackage[utf8]{inputenc}
  \usepackage[spanish]{babel}
  ```
- **Nunca** copiar texto directamente desde fuentes externas sin verificar encoding.

### 2. Paquetes Faltantes
**Errores típicos:**
- `Environment tikzpicture undefined` → Falta `\usepackage{tikz}`.
- `Environment lstlisting undefined` → Falta `\usepackage{listings}`.
- `Undefined control sequence \tableheader` → Falta `\usepackage{xcolor,colortbl}`.

**Paquetes mínimos para documentos técnicos:**
```latex
\usepackage{amsmath,amssymb,amsthm}       % Matemáticas
\usepackage[margin=2cm]{geometry}         % Márgenes
\usepackage{graphicx}                    % Imágenes
\usepackage{booktabs}                     % Tablas profesionales
\usepackage{array}                       % Mejoras para tablas
\usepackage{multirow}                     % Celdas multi-fila
\usepackage{hyperref}                     % Hipervínculos
\usepackage{enumitem}                    % Listas mejoradas
\usepackage{xcolor}                      % Colores
\usepackage{fancyhdr}                    % Encabezados/pies
\usepackage{listings}                    % Código fuente
\usepackage{colortbl}                     % Colores en tablas
\usepackage{longtable}                   % Tablas largas
```

### 3. Problemas con `fancyhdr`
**Error:**
```
Package fancyhdr Warning: \headheight is too small (12.0pt).
```

**Solución:**
Agregar en el preámbulo:
```latex
\setlength{\headheight}{14pt}
```

### 4. Diagramas con TikZ
**Error:**
```
Environment tikzpicture undefined.
```

**Solución:**
- Asegurar que `\usepackage{tikz}` esté en el preámbulo.
- **Alternativa recomendada para Krailynd:** Usar **Mermaid** (via `generate_diagram.py`) y enviar como PNG. TikZ es potente pero pesado para documentos rápidos.
- Ejemplo de diagrama alternativo:
  ```bash
  python3 ~/.hermes/scripts/generate_diagram.py "graph TD; A-->B;" --type mermaid --format png --output /tmp/diagrama.png
  ```

### 5. Listados de Código (listings)
**Error:**
```
Environment lstlisting undefined.
```

**Solución:**
Incluir en el preámbulo:
```latex
\usepackage{listings}
\lstset{
    basicstyle=\ttfamily\footnotesize,
    breaklines=true,
    frame=lines,
    backgroundcolor=\color{gray!5},
    keywordstyle=\color{blue},
    stringstyle=\color{red},
    commentstyle=\color{green!50!black},
    numbers=left,
    numberstyle=\tiny
}
```

**Recomendación para Krailynd:**
- Para **código corto** (<20 líneas): Usar ambiente `verbatim` o `lstlisting`.
- Para **código largo**: Enviar como archivo `.py`/`.cpp` adjunto (no en el PDF).

---

## ✅ Plantillas Validadas para Krailynd

### 1. Plantilla Básica para Informes Técnicos
```latex
% Compile: pdflatex FILENAME.tex | latexmk -pdf FILENAME.tex
\documentclass[12pt,a4paper]{article}
\usepackage[T1]{fontenc}
\usepackage[utf8]{inputenc}
\usepackage[spanish]{babel}
\usepackage[margin=2cm]{geometry}
\usepackage{amsmath,amssymb}
\usepackage{graphicx}
\usepackage{booktabs}
\usepackage{array}
\usepackage{hyperref}
\usepackage{xcolor}
\usepackage{fancyhdr}
\usepackage{listings}
\usepackage{colortbl}

\setlength{\headheight}{14pt}

\pagestyle{fancy}
\fancyhf{}
\fancyhead[L]{\small\textsf{Título del Documento}}
\fancyhead[R]{\small\textsf{Krailynd - Robótica 2025}}
\fancyfoot[C]{\small\thepage}

\title{\large\bfseries Título del Documento}
\author{\large YOUR_NAME (Krailynd) \\ \normalsize Curso: Robótica 2025}
\date{\today}

\begin{document}
\maketitle

\section*{Resumen Ejecutivo}
[Contenido breve y directo]

\newpage
\tableofcontents
\newpage

[Contenido principal]

\end{document}
```

### 2. Plantilla para Propuestas de Hackathon MINEDU
**Basada en los documentos generados para Krailynd en julio 2026.**

```latex
% Compile: pdflatex FILENAME.tex
\documentclass[12pt,a4paper]{article}
\usepackage[T1]{fontenc}
\usepackage[utf8]{inputenc}
\usepackage[spanish]{babel}
\usepackage[margin=2cm]{geometry}
\usepackage{amsmath}
\usepackage{graphicx}
\usepackage{booktabs}
\usepackage{array}
\usepackage{hyperref}
\usepackage{xcolor}
\usepackage{fancyhdr}
\usepackage{longtable}

\setlength{\headheight}{14pt}

\pagestyle{fancy}
\fancyhf{}
\fancyhead[L]{\small\textsf{Propuestas Hackathon MINEDU 2026}}
\fancyhead[R]{\small\textsf{Krailynd - Robótica 2025}}
\fancyfoot[C]{\small\thepage}

\title{\large\bfseries Propuestas para Hackathon MINEDU 2026 \\ \normalsize\bfseries Categoría C - Estudiantes de Secundaria}
\author{\large YOUR_NAME (Krailynd) \\ \normalsize Curso: Robótica 2025 \\ \normalsize Ica, Perú}
\date{}

\begin{document}

\maketitle

\begin{center}
\line(1,0){250}
\end{center}

\section*{Resumen Ejecutivo}
\begin{itemize}
    \item \textbf{Evento:} Hackathon en Tecnologías Digitales 2026 (MINEDU/DITE).
    \item \textbf{Categoría:} C (Estudiantes de 3ro, 4to y 5to de secundaria).
    \item \textbf{Requisitos clave:} Desarrollo \textbf{presencial}, hardware + software, enfoque local (Ica).
    \item \textbf{Propuestas:} 3 soluciones técnicas (SafeSchool-UV, AquaSmart Ica, SismoAlert Ica).
    \item \textbf{Recomendadas:} SafeSchool-UV y AquaSmart Ica (mejor alineación con desafíos y recursos disponibles).
\end{itemize}

\begin{center}
\fcolorbox{blue}{white}{\parbox[t]{0.95\linewidth}{\vspace*{5pt}
    \textbf{Enlaces clave:}
    \begin{itemize}
        \item Bases oficiales 2024: \url{https://repositorio.perueduca.pe/webs/2024/hackathon/bases-hackathon.pdf}
        \item Hackathon 2025 (Gob.pe): \url{https://www.gob.pe/institucion/minedu/noticias/1220955}
        \item Hackathon 2024 (Andina): \url{https://andina.pe/agencia/noticia-gran-hackathon-2024-994005.aspx}
    \end{itemize}
\vspace*{5pt}}}
\end{center}

\newpage

\tableofcontents
\newpage

\section{Antecedentes Relevantes}
\subsection*{Fuentes Oficiales y Proyectos Ganadores}
\begin{longtable}{|p{2cm}|p{8cm}|p{4cm}|}
\hline
\textbf{Año} & \textbf{Descripción} & \textbf{Enlace} \\ \hline
2025 & Hackathon MINEDU: Proyectos ganadores en IA + Robótica + STEAM (TargAiSquad, AILearn). & \url{https://www.gob.pe/institucion/minedu/noticias/1220955} \\ \hline
2025 & Hackathon MINEDU: 204 participantes (expertos, docentes, estudiantes). & \url{https://www.gob.pe/institucion/minedu/noticias/1220259} \\ \hline
2024 & Hackathon Bicentenario: 132 estudiantes de 18 regiones. Proyectos para discapacidad y agricultura. & \url{https://andina.pe/agencia/noticia-gran-hackathon-2024-994005.aspx} \\ \hline
2024 & Bases Hackathon 2024 (PDF oficial). & \url{https://repositorio.perueduca.pe/webs/2024/hackathon/bases-hackathon.pdf} \\ \hline
2023 & Proyectos ganadores: Inti Ñawina (mochila con visión artificial), mecanismo de recolección de basura. & \url{https://www.gob.pe/institucion/minedu/noticias/702476} \\ \hline
\end{longtable}

\section{Requisitos del Evento}
\begin{itemize}
    \item \textbf{Desarrollo presencial:} Las propuestas \textbf{deben construirse durante el evento} (no se aceptan proyectos pre-desarrollados).
    \item \textbf{Hardware + Software:} Las soluciones \textbf{deben incluir una maqueta física + código funcional} (ej: Arduino/ESP32 + sensores).
    \item \textbf{Enfoque local:} Se valora que resuelvan problemas \textbf{específicos de Ica} (radiación UV, escasez de agua, sismos).
    \item \textbf{Duración:} 3 días (diseño, programación, presentación).
\end{itemize}

\section{Desafíos Oficiales 2026}
[Contenido de la tabla de desafíos]

[Resto del documento...]
\end{document}
```

---

## 🎯 Preferencias Específicas de Krailynd

### 1. Estilo de Documentos
- **Brevedad:** "Sin humo" (sin texto innecesario). Krailynd prefiere **documentos directos y accionables**.
- **Estructura:** Usar **listas, tablas y secciones claras** en lugar de párrafos largos.
- **Enlaces:** **Todos los enlaces deben ser verificables y funcionales** (priorizar fuentes oficiales como Gob.pe, Andina, PerúEduca).

### 2. Contenido para Hackathons
- **Enfoque:** Priorizar **soluciones de hardware + software** (no apps puras).
- **Ejemplos válidos:**
  - SafeSchool-UV (sensor UV + toldo automático + Arduino).
  - AquaSmart Ica (sensor humedad + bomba + ESP32).
- **Ejemplos no válidos:** Apps móviles o web que no incluyan componente físico.

### 3. Entrega de Documentos
- **Formato preferido:** **PDF compilado** (listo para enviar a profesores).
- **Alternativa:** **LaTeX + instrucciones de compilación** (si no hay pdflatex disponible).
- **WhatsApp:** Si el documento supera **1500 caracteres**, enviarlo como archivo adjunto.

### 4. Bibliografía y Fuentes
- **Formato:** Incluir **enlaces directos** en tablas o listas (no al final del documento).
- **Ejemplo:**
  ```latex
  \begin{longtable}{|p{2cm}|p{8cm}|p{4cm}|}
  \hline
  Año & Descripción & Enlace \\ \hline
  2024 & Bases oficiales & \url{https://repositorio.perueduca.pe/...} \\ \hline
  \end{longtable}
  ```

---

## 📊 Checklist para Validar Documentos LaTeX

### Antes de Enviar a Krailynd:
- [ ] **Compila sin errores** (usar `pdflatex` o `latexmk`).
- [ ] **Todos los caracteres especiales** (tildes, ñ) se visualizan correctamente.
- [ ] **Los enlaces (URLs)** son funcionales y usan `\url{...}`.
- [ ] **Las tablas** no desbordan el ancho de página (usar `p{width}` en columnas).
- [ ] **Las imágenes** tienen rutas absolutas o están incrustadas (evitar rutas relativas).
- [ ] **El documento** incluye portada, resumen ejecutivo y tabla de contenidos.
- [ ] **El contenido** está ordenado por prioridad (lo más importante primero).

---

## 🔧 Herramientas para Generación de PDFs

### 1. Compilación Local (Preferida)
```bash
# Compilar con pdflatex (genera PDF directamente)
pdflatex /tmp/documento.tex

# Compilar con latexmk (recomendado para documentos complejos)
latexmk -pdf /tmp/documento.tex

# Limpiar archivos temporales
rm /tmp/documento.aux /tmp/documento.log /tmp/documento.out
```

### 2. Compilación con ReportLab (Python)
**Para PDFs simples sin LaTeX:**
```python
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import A4
from reportlab.lib.units import inch

c = canvas.Canvas("/tmp/output.pdf", pagesize=A4)
c.setFont("Helvetica", 12)
c.drawString(1*inch, 10*inch, "Título del Documento")
c.save()
```

**Nota:** ReportLab es útil para PDFs **sin fórmulas matemáticas**. Para matemáticas, **siempre usar LaTeX**.

### 3. Envío por WhatsApp
```bash
# Enviar PDF compilado
~/.hermes/scripts/hermes_send_file.sh /tmp/documento.pdf document YOUR_WHATSAPP_NUMBER "Título del Documento"

# Enviar LaTeX + instrucciones
~/.hermes/scripts/hermes_send_file.sh /tmp/documento.tex document YOUR_WHATSAPP_NUMBER "Documento LaTeX - Compilar con pdflatex"
```

---

## 📚 Recursos Adicionales

### 1. Tutoriales de LaTeX para Krailynd
- [Overleaf (Editor Online)](https://www.overleaf.com/): Para editar y compilar LaTeX en la nube.
- [LaTeX Wikibook](https://es.wikibooks.org/wiki/Manual_de_LaTeX): Guía completa en español.
- [CTAN (Paquetes LaTeX)](https://ctan.org/): Repositorio oficial de paquetes.

### 2. Plantillas Reutilizables
- **Plantilla básica:** `/tmp/hermes_template_basico.tex` (generada en julio 2026).
- **Plantilla Hackathon MINEDU:** `/tmp/propuestas_hackathon_minedu_2026_optimizado.tex` (validada por Krailynd).

### 3. Validación de Enlaces
**Herramienta para verificar enlaces en documentos:**
```bash
# Extraer URLs de un archivo .tex y validarlos
grep -oE "\\url\{[^}]+\}" documento.tex | sed 's/\\url\{|}/g' | xargs -I {} curl -s -o /dev/null -w "{}: %{http_code}\n" {}
```

---

## 📝 Notas de Sesión (Julio 2026)

### Correcciones Aplicadas en Sesión
1. **Problema:** Documento LaTeX con errores de encoding (caracteres Unicode no reconocidos).
   - **Solución:** Usar `\usepackage[utf8]{inputenc}` + `\usepackage[spanish]{babel}`.
   - **Ejemplo:** `propuestas_hackathon_minedu_2026_corregido.tex` (16 páginas, sin errores).

2. **Problema:** Documento demasiado largo y con "humo" (texto innecesario).
   - **Solución:** Redujimos de **16 páginas a 6 páginas** (versión optimizada).
   - **Ejemplo:** `propuestas_hackathon_minedu_2026_optimizado.tex`.

3. **Problema:** Faltaban enlaces oficiales y bibliografía.
   - **Solución:** Agregamos **tabla de antecedentes con 6 enlaces verificados** (Gob.pe, Andina, PerúEduca).

4. **Problema:** Krailynd pidió **requisitos del evento** (desarrollo presencial, hardware + software).
   - **Solución:** Agregamos **sección "Requisitos del Evento"** con los 3 puntos clave.

### Preferencias Confirmadas
- ✅ **"Sin humo"**: Krailynd prefiere documentos **cortos, directos y con información accionable**. - ✅ **Enlaces verificados**: Todos los enlaces deben **funcionar y ser de fuentes oficiales**. - ✅ **Estructura clara**: Usar **tablas, listas y secciones** para organizar la información. - ✅ **Hardware + Software**: Las propuestas para Hackathons **deben incluir componente físico**. ---

## 🔄 Actualizaciones Futuras

### Pendientes para Proximas Sesiones:
1. **Generar plantilla reutilizable** para futuras Hackathons (basada en el documento optimizado de julio 2026).
2. **Automatizar validación de enlaces** en documentos LaTeX antes de enviarlos.
3. **Crear script** para convertir Markdown → LaTeX con formato predefinido para Krailynd.

---

*Última actualización: 3 de julio de 2026*
*Responsable: Hermes Agent (SahaCloud)*
