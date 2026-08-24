---
name: data-science-analytics
description: Skill de Ciencia de Datos y Análisis de Negocios en Windows (E:\entornos\data-science). Análisis exploratorio (EDA), Polars, Pandas, Scikit-Learn y dashboards.
---

# Data Science & Business Analytics Skill (Windows SSH)

Skill especialista para ejecución de proyectos de Ciencia de Datos, Análisis Estadístico, Limpieza y EDA en Windows PC (`windows-krai`).

---

## 1. CONFIGURACIÓN DEL ENTORNO EN WINDOWS

- **Host SSH**: `windows-krai` (IP Tailscale `YOUR_TAILSCALE_IP`).
- **Python Executable**: `E:\entornos\data-science\python.exe`
- **Librerías Clave**: Pandas, Polars, NumPy, SciPy, Scikit-Learn, Matplotlib, Seaborn, Plotly.

---

## 2. COMANDO DE EJECUCIÓN AUTÓNOMA

Para ejecutar un script o análisis en Windows desde Hermes:

```bash
ssh -o RemoteCommand=none -o RequestTTY=no windows-krai "E:\entornos\data-science\python.exe -c \"import polars as pl, pandas as pd; print('Entorno Data Science OK')\""
```

O enviar un script `.py` local a Windows y ejecutarlo:
```bash
scp -q -o RemoteCommand=none -o RequestTTY=no /tmp/script.py windows-krai:E:\entornos\script.py
ssh -o RemoteCommand=none -o RequestTTY=no windows-krai "E:\entornos\data-science\python.exe E:\entornos\script.py"
```

---

## 3. ENTREGABLES DE TRABAJO Y ANÁLISIS

1. **Generación de Gráficos de Alta Resolución**:
   Guardar gráficos en `E:\YOUR_VAULT\Media\` o en la carpeta del proyecto para incrustar directamente en Obsidian o reportes.
2. **Exportación de Datasets**:
   Salida limpia en formato Parquet (`.parquet`) o CSV optimizado.
