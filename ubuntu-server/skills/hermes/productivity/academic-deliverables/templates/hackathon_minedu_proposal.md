# Hackathon MINEDU 2026 - Plantilla Estándar para Propuestas

## Contexto
Plantilla estandarizada para propuestas de **Hackathon MINEDU** (Categoría C: Estudiantes de Secundaria), diseñada específicamente para **Krailynd (YOUR_NAME)**. Basada en los documentos generados y validados en **julio 2026** durante la preparación para la Hackathon en Tecnologías Digitales 2026.

**Requisitos clave del evento:**
- Desarrollo **presencial** (3 días).
- Soluciones de **hardware + software** (no apps puras).
- Enfoque en **problemáticas locales** (ej: Ica).

---

## 📄 Estructura de la Plantilla

### 1. Portada
```latex
\title{\large\bfseries Propuestas para Hackathon MINEDU 2026 \\ \normalsize\bfseries Categoría C - Estudiantes de Secundaria}
\author{\large YOUR_NAME (Krailynd) \\ \normalsize Curso: Robótica 2025 \\ \normalsize Ica, Perú}
\date{}
```

### 2. Resumen Ejecutivo (1 página máximo)
**Contenido obligatorio:**
- Contexto del evento (MINEDU/DITE).
- Número de propuestas presentadas.
- **Recomendación clara** (ej: "Priorizar SafeSchool-UV o AquaSmart Ica").
- **Enlaces clave** a bases oficiales (en caja destacada).

**Ejemplo:**
```latex
\section*{Resumen Ejecutivo}
\begin{itemize}
    \item \textbf{Evento:} Hackathon en Tecnologías Digitales 2026 (MINEDU/DITE).
    \item \textbf{Categoría:} C (Estudiantes de 3ro, 4to y 5to de secundaria).
    \item \textbf{Requisitos clave:} Desarrollo \textbf{presencial}, hardware + software, enfoque local (Ica).
    \item \textbf{Propuestas:} 3 soluciones técnicas (SafeSchool-UV, AquaSmart Ica, SismoAlert Ica).
    \item \textbf{Recomendadas:} SafeSchool-UV y AquaSmart Ica.
\end{itemize}

\begin{center}
\fcolorbox{blue}{white}{\parbox[t]{0.95\linewidth}{\vspace*{5pt}
    \textbf{Enlaces clave:}
    \begin{itemize}
        \item Bases oficiales 2024: \url{https://repositorio.perueduca.pe/webs/2024/hackathon/bases-hackathon.pdf}
        \item Hackathon 2025: \url{https://www.gob.pe/institucion/minedu/noticias/1220955}
        \item Hackathon 2024: \url{https://andina.pe/agencia/noticia-gran-hackathon-2024-994005.aspx}
    \end{itemize}
\vspace*{5pt}}}
\end{center}
```

---

### 3. Tabla de Contenidos
```latex
\newpage
\tableofcontents
\newpage
```

---

### 4. Antecedentes Relevantes
**Formato:** Tabla con 3 columnas: **Año | Descripción | Enlace**.

**Ejemplo:**
```latex
\section{Antecedentes Relevantes}
\subsection*{Fuentes Oficiales y Proyectos Ganadores}
\begin{longtable}{|p{2cm}|p{8cm}|p{4cm}|}
\hline
\textbf{Año} & \textbf{Descripción} & \textbf{Enlace} \\ \hline
2025 & Hackathon MINEDU: Proyectos ganadores en IA + Robótica + STEAM (TargAiSquad, AILearn). & \url{https://www.gob.pe/institucion/minedu/noticias/1220955} \\ \hline
2024 & Hackathon Bicentenario: 132 estudiantes de 18 regiones. Proyectos para discapacidad y agricultura. & \url{https://andina.pe/agencia/noticia-gran-hackathon-2024-994005.aspx} \\ \hline
2024 & Bases Hackathon 2024 (PDF oficial). & \url{https://repositorio.perueduca.pe/webs/2024/hackathon/bases-hackathon.pdf} \\ \hline
2023 & Proyectos ganadores: Inti Ñawina (mochila con visión artificial). & \url{https://www.gob.pe/institucion/minedu/noticias/702476} \\ \hline
\end{longtable}
```

**Requisitos:**
- Solo incluir **fuentes oficiales** (Gob.pe, Andina, PerúEduca, Slideshare).
- **Verificar que todos los enlaces funcionen** antes de enviar.

---

### 5. Requisitos del Evento
**Sección crítica para Krailynd.** Incluir:
```latex
\section{Requisitos del Evento}
\begin{itemize}
    \item \textbf{Desarrollo presencial:} Las propuestas \textbf{deben construirse durante el evento} (3 días). No se aceptan proyectos pre-desarrollados.
    \item \textbf{Hardware + Software:} Las soluciones \textbf{deben incluir una maqueta física + código funcional} (ej: Arduino/ESP32 + sensores).
    \item \textbf{Enfoque local:} Se valora que resuelvan problemas \textbf{específicos de Ica} (radiación UV, escasez de agua, sismos).
    \item \textbf{Duración:} 3 días (Día 1: Diseño, Día 2: Programación, Día 3: Presentación).
\end{itemize}
```

---

### 6. Desafíos Oficiales 2026
**Formato:** Tabla simple con los 4 desafíos de la **Categoría C**.

**Ejemplo:**
```latex
\section{Desafíos Oficiales 2026}
\begin{table}[h!]
\centering
\caption{Desafíos para Estudiantes (Categoría C)}
\begin{tabular}{|p{2cm}|p{10cm}|}
\hline
\textbf{Desafío} & \textbf{Descripción} \\ \hline
Desafío 1 & Solución tecnológica de alerta temprana comunitaria (deslizamientos, huaycos, inundaciones). \\ \hline
Desafío 2 & Sistema para uso eficiente del agua en regadío de cultivos. \\ \hline
Desafío 3 & Sistema para ventilación natural o alertas para tratamiento médico (ej: TB). \\ \hline
Desafío 4 & Innovación Local: Resolver problemática específica de la comunidad/región. \\ \hline
\end{tabular}
\end{table}
```

---

### 7. Propuestas Técnicas
**Formato por propuesta:**
1. **Nombre completo** (ej: SafeSchool-UV: Sistema Automatizado de Sombreado y Alerta de Radiación UV Escolar).
2. **Desafío al que postula** (ej: Desafío 4: Innovación Local).
3. **Problemática** (1-2 líneas).
4. **Solución propuesta** (lista numerada con 3-4 puntos).
5. **Especificaciones técnicas** (tabla con: Componente | Especificación | Función).
6. **Diagrama de conexiones** (opcional, usar Mermaid o TikZ).
7. **Lógica de programación** (pseudocódigo o código C++ **solo si es corto**).
8. **Impacto esperado** (lista con 2-3 puntos).
9. **Alineación con ODS** (tabla: ODS | Descripción | Contribución).
10. **Presupuesto estimado** (tabla: Componente | Costo (S/) | Dónde comprar).

**Ejemplo (SafeSchool-UV):**
```latex
\subsection{SafeSchool-UV}
\begin{itemize}
    \item \textbf{Desafío:} 4 (Innovación Local).
    \item \textbf{Problemática:} Altos índices UV en Ica (11-14, categoría "Extremo" según OMS).
    \item \textbf{Solución:} Sistema automatizado con sensor UV (GUVA-S12SD) + toldo + alertas (LED/buzzer).
    \item \textbf{Componentes clave:} Arduino Uno, motorreductor 12V, display OLED, tela resistente UV.
    \item \textbf{Impacto:} Reduce riesgo de cáncer de piel en estudiantes.
    \item \textbf{ODS:} 3 (Salud), 4 (Educación), 11 (Ciudades sostenibles).
    \item \textbf{Costo:} S/ 270-460.
    \item \textbf{Antecedentes:} Similar a SATC (2024, alertas tempranas).
\end{itemize}

\subsubsection{Especificaciones Técnicas}
\begin{table}[h!]
\centering
\caption{Componentes de SafeSchool-UV}
\begin{tabular}{|p{4cm}|p{4cm}|p{5cm}|}
\hline
\textbf{Componente} & \textbf{Especificación} & \textbf{Función} \\ \hline
Microcontrolador & Arduino Uno / ESP32 & Cerebro del sistema. \\ \hline
Sensor UV & GUVA-S12SD & Mide índice UV (0-15). \\ \hline
Display & OLED 0.96" (SSD1306) & Muestra índice UV y estado. \\ \hline
Motorreductor & 12V DC & Despliega/retrae el toldo. \\ \hline
\end{tabular}
\end{table}
```

**Recomendaciones:**
- **Código largo:** No incluir en el PDF. Enviar como archivo `.cpp` adjunto.
- **Diagramas:** Usar **Mermaid** (via `generate_diagram.py`) y enviar como PNG.

---

### 8. Comparativa de Propuestas
**Formato:** Tabla con criterios de evaluación.

**Ejemplo:**
```latex
\section{Comparativa de Propuestas}
\begin{table}[h!]
\centering
\caption{Comparativa}
\begin{tabular}{|p{3cm}|p{2cm}|p{2cm}|p{2cm}|}
\hline
\textbf{Criterio} & \textbf{SafeSchool-UV} & \textbf{AquaSmart Ica} & \textbf{SismoAlert Ica} \\ \hline
Alineación con bases & ⭐⭐⭐⭐⭐ & ⭐⭐⭐⭐⭐ & ⭐⭐⭐⭐ \\ \hline
Impacto en Ica & ⭐⭐⭐⭐⭐ & ⭐⭐⭐⭐⭐ & ⭐⭐⭐⭐ \\ \hline
Viabilidad técnica & ⭐⭐⭐⭐⭐ & ⭐⭐⭐⭐⭐ & ⭐⭐⭐⭐ \\ \hline
Costo (S/) & 270-460 & 205-320 & 250-400 \\ \hline
	extbf{Recomendación} & 	extbf{🥇 Mejor opción} & 	extbf{🥇 Mejor opción} & 🥉 Buena opción \\ \hline
\end{tabular}
\end{table}
```

---

### 9. Recursos y Tutoriales
**Formato:** Tabla con enlaces a tutoriales y guías.

**Ejemplo:**
```latex
\section{Recursos y Tutoriales}
\begin{longtable}{|p{5cm}|p{5cm}|p{4cm}|}
\hline
\textbf{Recurso} & \textbf{Descripción} & \textbf{Enlace} \\ \hline
Sensor UV GUVA-S12SD & Tutorial con Arduino & \url{https://lastminuteengineers.com/guva-s12sd-uv-sensor-arduino-tutorial/} \\ \hline
Sensor YL-69 & Tutorial con ESP32 & \url{https://randomnerdtutorials.com/esp32-esp8266-moisture-sensor/} \\ \hline
\end{longtable}
```

---

### 10. Dónde Comprar en Perú
**Formato:** Lista corta por categoría.

**Ejemplo:**
```latex
\section{Dónde Comprar en Perú}
\begin{itemize}
    \item \textbf{Sensores, Arduino, ESP32:} Amazon Perú, MercadoLibre.
    \item \textbf{Madera, poleas, mangueras:} Ferreterías locales (Ica).
    \item \textbf{LEDs, cables, resistencias:} Radio Shack, tiendas de electrónica.
\end{itemize}
```

---

### 11. Conclusión
**Contenido obligatorio:**
- Recomendación final (SafeSchool-UV o AquaSmart Ica).
- Justificación breve (2-3 puntos).
- Compromiso como estudiante.

**Ejemplo:**
```latex
\section{Conclusión}
\begin{itemize}
    \item \textbf{Recomendación final:} SafeSchool-UV o AquaSmart Ica.
    \item Ambas resuelven problemas reales de Ica y tienen antecedentes en Hackathons anteriores.
    \item Compromiso: Desarrollar el prototipo durante el evento, documentar el proceso y presentar una solución funcional.
\end{itemize}
```

---

## 📥 Paquetes LaTeX Requeridos

**Paquetes mínimos para la plantilla:**
```latex
\usepackage[T1]{fontenc}          % Soporte para caracteres especiales
\usepackage[utf8]{inputenc}        % Codificación UTF-8
\usepackage[spanish]{babel}        % Idioma español
\usepackage[margin=2cm]{geometry}  % Márgenes
\usepackage{amsmath}               % Matemáticas
\usepackage{graphicx}              % Imágenes
\usepackage{booktabs}              % Tablas profesionales
\usepackage{array}                 % Mejoras para tablas
\usepackage{multirow}              % Celdas multi-fila
\usepackage{hyperref}              % Hipervínculos
\usepackage{xcolor}                % Colores
\usepackage{fancyhdr}              % Encabezados/pies
\usepackage{listings}              % Código fuente
\usepackage{colortbl}              % Colores en tablas
\usepackage{longtable}             % Tablas largas
```

---

## 🔧 Compilación y Entrega

### Compilación
```bash
# Compilar con pdflatex (recomendado)
pdflatex /tmp/propuesta.tex

# Compilar con latexmk (para documentos complejos)
latexmk -pdf /tmp/propuesta.tex

# Limpiar archivos temporales
rm /tmp/propuesta.aux /tmp/propuesta.log /tmp/propuesta.out
```

### Entrega por WhatsApp
```bash
# Enviar PDF compilado
~/.hermes/scripts/hermes_send_file.sh /tmp/propuesta.pdf document YOUR_WHATSAPP_NUMBER "Propuesta Hackathon MINEDU 2026 - Krailynd"

# Enviar LaTeX + instrucciones (si no hay pdflatex)
~/.hermes/scripts/hermes_send_file.sh /tmp/propuesta.tex document YOUR_WHATSAPP_NUMBER "Documento LaTeX - Compilar con pdflatex"
```

---

## 📌 Checklist Antes de Enviar

- [ ] **Compila sin errores** (probar con `pdflatex`).
- [ ] **Todos los caracteres especiales** (tildes, ñ) se visualizan correctamente.
- [ ] **Los enlaces (URLs)** son funcionales y usan `\url{...}`.
- [ ] **Las tablas** no desbordan el ancho de página.
- [ ] **El documento** incluye:
  - Portada.
  - Resumen ejecutivo.
  - Tabla de contenidos.
  - Antecedentes con enlaces.
  - Requisitos del evento.
  - Propuestas técnicas.
  - Comparativa.
  - Recursos.
  - Conclusión.
- [ ] **El contenido** está ordenado por prioridad (lo más importante primero).
- [ ] **No hay "humo"** (texto innecesario).

---

## 🎯 Ejemplo Completo (Código LaTeX)

```latex
% Compile: pdflatex propuestas_hackathon_minedu_2026.tex
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
[Contenido del resumen]

\begin{center}
\fcolorbox{blue}{white}{\parbox[t]{0.95\linewidth}{\vspace*{5pt}
    \textbf{Enlaces clave:}
    \begin{itemize}
        \item Bases oficiales 2024: \url{https://repositorio.perueduca.pe/webs/2024/hackathon/bases-hackathon.pdf}
    \end{itemize}
\vspace*{5pt}}}
\end{center}

\newpage
\tableofcontents
\newpage

\section{Antecedentes Relevantes}
[Tabla de antecedentes]

\section{Requisitos del Evento}
[Lista de requisitos]

\section{Desafíos Oficiales 2026}
[Tabla de desafíos]

\section{Propuestas Técnicas}
[Subsecciones por propuesta]

\section{Comparativa de Propuestas}
[Tabla comparativa]

\section{Recursos y Tutoriales}
[Tabla de recursos]

\section{Dónde Comprar en Perú}
[Lista de proveedores]

\section{Conclusión}
[Conclusión breve]

\begin{center}
\line(1,0){250}
\end{center}

\begin{flushright}
\textbf{YOUR_NAME} \\
Krailynd - Robótica 2025 \\
Ica, Perú
\end{flushright}

\end{document}
```

---

## 📚 Recursos Adicionales

### 1. Plantillas Reutilizables
- **Plantilla básica:** [Ver en GitHub](https://github.com/) (próximamente).
- **Ejemplo validado:** `/tmp/propuestas_hackathon_minedu_2026_optimizado.tex` (6 páginas, julio 2026).

### 2. Herramientas para Generación de Diagramas
```bash
# Generar diagrama Mermaid y enviar como PNG
python3 ~/.hermes/scripts/generate_diagram.py "graph TD; A-->B;" \
 --type mermaid \
 --format png \
 --output /tmp/diagrama.png

# Enviar por WhatsApp
~/.hermes/scripts/hermes_send_file.sh /tmp/diagrama.png image YOUR_WHATSAPP_NUMBER "Diagrama de conexiones"
```

### 3. Validación de Enlaces
```bash
# Extraer URLs de un archivo .tex y validarlos
grep -oE "\\url\{[^}]+\}" propuestas.tex | sed 's/\\url\{|}/g' | xargs -I {} curl -s -o /dev/null -w "{}: %{http_code}\n" {}
```

---

## 📝 Notas de Sesión (Julio 2026)

### Lecciones Aprendidas
1. **Krailynd prefiere documentos cortos y directos** (6 páginas máximo para propuestas de Hackathon).
2. **Los enlaces deben ser verificables** (priorizar fuentes oficiales como Gob.pe, Andina, PerúEduca).
3. **Las propuestas deben incluir:**
   - Requisitos del evento (desarrollo presencial, hardware + software).
   - Antecedentes con enlaces.
   - Comparativa de opciones.
4. **Evitar:**
   - Texto innecesario ("humo").
   - Tablas que desbordan el ancho de página.
   - Países no verificados.

### Mejoras Futuras
- [ ] Crear un **script** para generar automáticamente propuestas de Hackathon con esta plantilla.
- [ ] Incluir **diagramas predefinidos** (Mermaid) para las propuestas más comunes.
- [ ] Agregar **presupuestos detallados** por proveedor (Amazon, MercadoLibre, ferreterías locales).

---

*Última actualización: 3 de julio de 2026*
*Responsable: Hermes Agent (SahaCloud)*
