# 📌 **Técnicas y Workflows para Búsquedas de Recursos Gratuitos en la Web**
## **Lecciones Aprendidas en la Sesión con Krailynd (Julio 2026)**

---

## 🎯 **Contexto de la Sesión**

**Objetivo del Usuario:**
Krailynd solicitó una **búsqueda exhaustiva de recursos GRATIS y Open Source** para creación de contenido en YouTube, con énfasis en:
- Cursos para YouTube (estilo La Marmota Espacial / El Último Círculo).
- Recursos para **DaVinci Resolve** (plugins, plantillas, cursos).
- Recursos para **Blender** (cursos, modelos 3D, add-ons).
- Recursos para **guionización, diseño gráfico, sonido y assets**.

**Requisitos Clave:**
- **Todos los enlaces deben funcionar** (verificados en julio 2026).
- **Más de 500 enlaces** en total (200+ por categoría).
- **Formato estructurado** (PDF con tablas y recomendaciones).

---

## 🔍 **Técnicas de Búsqueda Aplicadas**

### **1. Búsqueda por Categorías Específicas**
**Estrategia:**
- Dividir la búsqueda en **categorías claras** (ej: "DaVinci Resolve plugins", "Blender 3D models").
- Usar **operadores de búsqueda avanzada** (`site:github.com`, `filetype:pdf`).
- Priorizar **fuentes oficiales** (Blackmagic, Blender Foundation, YouTube Creator Academy).

**Consultas Ejemplo:**
```
free DaVinci Resolve plugins OFX 2026
free Blender 3D models OBJ FBX 2026
free screenwriting books PDF 2026
```

**Resultado:** Mayor precisión y menor ruido en los resultados.

---

### **2. Verificación de Enlaces**
**Estrategia:**
- **No incluir enlaces sin verificar** (evitar 404 o redirecciones).
- Usar `web_search` + `web_extract` para confirmar que los enlaces funcionan.
- **Probar manualmente** (si es posible) antes de entregarlos.

**Pitfall Identificado:**
- Algunos sitios (como SteamDB) **no permiten extracción directa** con `web_extract`.
- **Solución:** Usar `web_search` para encontrar enlaces y redirigir al usuario a la fuente oficial.

---

### **3. Estructuración de la Información**
**Estrategia:**
- **Organizar por categorías** (Cursos, Plugins, Plantillas, etc.).
- **Usar tablas** para comparar recursos (nombre, enlace, descripción, tipo).
- **Incluir sección de "Recomendaciones Finales"** con consejos prácticos.

**Ejemplo de Estructura:**
```markdown
### Cursos de DaVinci Resolve
| Nombre | Enlace | Descripción | Nivel |
|--------|--------|-------------|-------|
| Curso 1 | [Enlace] | Descripción | Principiante |
```

**Resultado:** Mayor legibilidad y fácil navegación.

---

### **4. Priorización de Recursos**
**Estrategia:**
- **Ordenar por relevancia** (plugins más populares primero).
- **Incluir columna de "Recomendación"** (⭐⭐⭐⭐⭐ para los mejores).
- **Destacar recursos "Tier 1"** (ej: Skyrim y Fallout 4 para mods).

**Ejemplo:**
```markdown
| Juego | Precio (PEN) | Mod Support | Recomendación |
|-------|--------------|-------------|----------------|
| Skyrim SE | 37 | ✅ Tier 1 | ⭐⭐⭐⭐⭐ |
```

---

### **5. Inclusión de Alternativas**
**Estrategia:**
- **No limitarse a una sola fuente** (GitHub, Archive.org, PDF Drive).
- **Incluir alternativas Open Source** (GIMP para Photoshop, Krita para dibujo).
- **Mencionar comunidades** (Reddit r/VideoEditing, Blender Artists).

---

## 🛠 **Workflows Optimizados**

### **Workflow 1: Búsqueda de Recursos para Software (DaVinci Resolve, Blender)**
**Pasos:**
1. Identificar el software (ej: DaVinci Resolve).
2. Buscar categorías relevantes:
   - Cursos y tutoriales.
   - Plugins/add-ons.
   - Plantillas/proyectos.
   - Manuales/documentación.
3. Usar consultas específicas:
   ```
   free DaVinci Resolve plugins 2026
   free Blender add-ons GitHub 2026
   ```
4. Verificar enlaces con `web_search` + `web_extract`.
5. Organizar en tablas por categoría.

**Herramientas Usadas:**
- `web_search` (encontrar recursos).
- `web_extract` (verificar contenido).
- `execute_code` (procesar datos y generar tablas).

---

### **Workflow 2: Búsqueda de Cursos y Libros**
**Pasos:**
1. Identificar el tema (ej: guionización, diseño gráfico).
2. Buscar en YouTube:
   ```
   curso de guionización para YouTube
   curso de diseño gráfico con GIMP
   ```
3. Buscar en PDF Drive:
   ```
   free screenwriting books PDF
   free graphic design books PDF
   ```
4. Incluir plantillas (ej: Google Docs).
5. Organizar por nivel (principiante, intermedio, avanzado).

**Fuentes Clave:** YouTube, PDF Drive, Google Docs.

---

### **Workflow 3: Búsqueda de Assets Gratuitos**
**Pasos:**
1. Identificar el tipo de asset (stock footage, imágenes, texturas).
2. Buscar en sitios especializados:
   - **Stock Footage:** Pexels, Pixabay, Mixkit.
   - **Imágenes:** Unsplash, Pixabay, Freepik.
   - **Texturas:** Texture Haven, Poly Haven, CC0 Textures.
3. Verificar licencias (CC0, Creative Commons, Royalty-Free).
4. Incluir enlaces directos a categorías relevantes.

---

## ⚠️ **Pitfalls y Soluciones**

| **Pitfall** | **Solución** | **Herramienta Usada** |
|-------------|--------------|-----------------------|
| Enlaces rotos o no funcionales | Verificar cada enlace antes de incluirlos | `web_extract` |
| Sitios que no permiten extracción (ej: SteamDB) | Usar `web_search` y redirigir a la fuente oficial | `web_search` |
| Demasiados resultados irrelevantes | Usar operadores de búsqueda avanzada | `web_search` con filtros |
| Falta de organización en la respuesta | Usar tablas y categorías claras | Markdown + `execute_code` |

---

## 📌 **Lecciones Aprendidas para Futuras Sesiones**

### **1. Prefieren Respuestas Estructuradas**
- **Krailynd** prefiere **tablas y listas organizadas** en lugar de párrafos largos.
- **Acción:** Usar **Markdown con tablas** para presentar datos (ej: juegos, cursos, plugins).

### **2. Priorizan Recursos Gratuitos y Open Source**
- **Krailynd** busca **soluciones sin costo** (evitar enlaces a cursos de pago o software premium).
- **Acción:** Filtrar resultados para incluir **solo recursos gratuitos o Open Source**.

### **3. Necesitan Enlaces que Funcionen**
- **Krailynd** exige que **todos los enlaces estén verificados** (no tolera 404 o redirecciones rotas).
- **Acción:** Usar `web_extract` para **confirmar que los enlaces devuelven contenido válido** antes de incluirlos.

### **4. Prefieren Formato PDF para Documentos Largos**
- **Krailynd** solicitó explícitamente un **PDF bien estructurado** (no solo texto plano o Markdown).
- **Acción:** Usar `reportlab` para generar **PDFs profesionales** con:
   - Portada.
   - Índice.
   - Tablas organizadas.
   - Secciones claras.

### **5. Buscan Cantidad + Calidad**
- **Krailynd** pidió **más de 500 enlaces** (200+ por categoría).
- **Acción:** Realizar **búsquedas exhaustivas** y **agrupar resultados por categorías** para cumplir con el requisito.

---

## 🎯 **Recomendaciones para Futuras Búsquedas**

### **Para Krailynd (y usuarios similares):**
1. **Siempre verificar enlaces** antes de entregarlos.
2. **Usar tablas** para organizar información (mejora la legibilidad).
3. **Priorizar recursos gratuitos** (evitar enlaces a cursos o software de pago).
4. **Incluir alternativas** por si un recurso no está disponible.
5. **Generar PDFs** para respuestas largas (usar `reportlab`).

### **Para Hermes:**
1. **Cargar el skill `web_search`** al inicio de sesiones de investigación.
2. **Usar `execute_code`** para procesar datos y generar tablas/PDFs.
3. **Verificar enlaces con `web_extract`** antes de incluirlos en respuestas.
4. **Organizar resultados por categorías** (facilita la navegación).
5. **Incluir una sección de "Recomendaciones"** con consejos prácticos.

---

## 📚 **Recursos Adicionales**

- **Guía de Búsqueda Avanzada en Google:** [Enlace](https://support.google.com/websearch/answer/2466433)
- **Lista de Operadores de Búsqueda:** [Enlace](https://ahrefs.com/blog/google-advanced-search-operators/)
- **Herramientas para Verificar Enlaces:** [Dead Link Checker](https://www.deadlinkchecker.com/)

---

**Nota:** Este documento se actualizará con nuevas técnicas y lecciones aprendidas en futuras sesiones.