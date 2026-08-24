---
name: jupyter-notebook-creator
description: Skill para creación autónoma, ejecución headless y exportación de Jupyter Notebooks (.ipynb) en Windows Anaconda/Jupyter Lab.
---

# Jupyter Notebook Creator & Runner Skill (Windows SSH)

Skill especialista para crear, ejecutar sin interfaz (headless) y exportar cuadernos de Jupyter (`.ipynb`) en Windows PC (`windows-krai`).

---

## 1. ENTORNO JUPYTER EN WINDOWS

- **Host SSH**: `windows-krai` (IP Tailscale `YOUR_TAILSCALE_IP`).
- **Conda Base**: `E:\anaconda`
- **Jupyter Tools**: `nbconvert`, `ipykernel`, `jupyterlab 4.6.2`.

---

## 2. CREACIÓN Y EJECUCIÓN AUTÓNOMA DE NOTEBOOKS

1. **Crear Cuaderno (.ipynb)**:
   Hermes escribe el JSON estructurado del `.ipynb` o usa `jupytext` / Python en Windows:
   ```bash
   ssh -o RemoteCommand=none -o RequestTTY=no windows-krai "E:\anaconda\python.exe -c \"import nbformat as nbf; nb = nbf.v4.new_notebook(); nb.cells.append(nbf.v4.new_markdown_cell('# Notebook Profesional')); nb.cells.append(nbf.v4.new_code_cell('import pandas as pd\nprint(\\\"Data Science Notebook\\\")')); nbf.write(nb, 'E:\\\\entornos\\\\mi_notebook.ipynb')\""
   ```

2. **Ejecutar Notebook Headless**:
   ```bash
   ssh -o RemoteCommand=none -o RequestTTY=no windows-krai "E:\entornos\data-science\Scripts\jupyter-nbconvert.exe --to notebook --execute E:\entornos\mi_notebook.ipynb --output E:\entornos\mi_notebook_ejecutado.ipynb"
   ```

3. **Exportar a HTML / PDF para Entregables de Trabajo**:
   ```bash
   ssh -o RemoteCommand=none -o RequestTTY=no windows-krai "E:\entornos\data-science\Scripts\jupyter-nbconvert.exe --to html E:\entornos\mi_notebook_ejecutado.ipynb"
   ```
