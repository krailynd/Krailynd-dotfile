---
name: academic-research
description: "Academic & Scientific Research skill: search ArXiv, PubMed, Semantic Scholar, download PDFs, extract text, summarize papers, and generate APA/IEEE citations."
version: 1.0.0
author: sahacloud
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [Academic, Research, ArXiv, PubMed, Papers, PDFs, APA, IEEE, Citations, Thesis]
prerequisites:
  commands: [curl, python3]
---

# /academic-research — Investigaciones Académicas y Papers

Herramienta completa para búsqueda, descarga y análisis de artículos científicos, tesis y literatura académica sin barreras.

---

## 1. Buscar Papers en ArXiv / PubMed

### ArXiv Search (API Libre)
```bash
python3 -c "
import urllib.request, xml.etree.ElementTree as ET
query = 'quantum computing'
url = f'http://export.arxiv.org/api/query?search_query=all:{query}&start=0&max_results=5'
data = urllib.request.urlopen(url).read()
root = ET.fromstring(data)
for entry in root.findall('{http://www.w3.org/2005/Atom}entry'):
    title = entry.find('{http://www.w3.org/2005/Atom}title').text.strip()
    summary = entry.find('{http://www.w3.org/2005/Atom}summary').text.strip()[:200]
    link = entry.find('{http://www.w3.org/2005/Atom}id').text
    print(f'• {title}\n  URL: {link}\n  Resumen: {summary}...\n')
"
```

---

## 2. Leer y Extraer Texto de PDFs Científicos Locales

Para analizar un paper en PDF descargado (`/tmp/paper.pdf`):

```bash
python3 -c "
import pypdf
reader = pypdf.PdfReader('/tmp/paper.pdf')
print(f'Total páginas: {len(reader.pages)}')
print('=== EXTRACTO PRIMERAS PÁGINAS ===')
for i in range(min(3, len(reader.pages))):
    print(f'--- Página {i+1} ---')
    print(reader.pages[i].extract_text()[:1000])
"
```

---

## 3. Formato de Citas (APA 7ª Edición / IEEE)

- **APA 7**: Apellido, N. (Año). Título del artículo. *Nombre de la Revista*, volumen(número), páginas. https://doi.org/xxx
- **IEEE**: [1] N. Apellido, "Título del artículo," *Nombre de la Revista*, vol. X, no. Y, pp. xx-yy, mes, año.
