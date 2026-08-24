---
name: data-charts
description: "Gráficos estadísticos con datos EXACTOS: barras, líneas, dispersión, histogramas, mapas de calor, tartas y gráficos combinados, renderizados con matplotlib. Usar SIEMPRE que la imagen represente números reales — ventas, notas, porcentajes, series temporales, encuestas. Un modelo de imagen inventa las barras; esto dibuja los datos que le das."
version: 1.0.0
author: sahacloud
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [Graficos, Estadisticas, Datos, Matplotlib, Visualizacion, Informes]
---

# /data-charts

## Por qué existe

**Un modelo de imagen no sabe dibujar datos.** Si le pides "gráfico de barras de ventas: enero 42, febrero 58", produce barras con alturas plausibles pero falsas, ejes sin correspondencia y etiquetas deformadas. Es una ilustración de un gráfico, no un gráfico.

Cuando hay números reales de por medio, esto no es negociable: se dibuja con matplotlib. Los píxeles corresponden a los datos.

## Intérprete correcto

matplotlib y pandas están **solo en el venv de Hermes**, no en el Python del sistema:

```bash
~/.hermes/hermes-agent/venv/bin/python script.py
```

El `python3` del sistema da `ModuleNotFoundError: No module named 'matplotlib'`. Comprobado.

## Plantilla base

Backend `Agg` obligatorio — no hay display en el servidor.

```python
import matplotlib
matplotlib.use("Agg")                     # sin esto falla en headless
import matplotlib.pyplot as plt

meses  = ["Ene", "Feb", "Mar", "Abr"]
ventas = [42, 58, 51, 73]

fig, ax = plt.subplots(figsize=(9, 5), dpi=160)
ax.bar(meses, ventas, color="#4C78A8")

ax.set_title("Ventas por mes", fontsize=15, weight="bold", pad=15)
ax.set_ylabel("Miles de €")
ax.spines[["top", "right"]].set_visible(False)     # quita el marco: menos ruido
ax.grid(axis="y", alpha=0.3)
ax.set_axisbelow(True)                             # rejilla DETRAS de las barras

for i, v in enumerate(ventas):                     # valores encima
    ax.text(i, v + max(ventas) * 0.02, str(v), ha="center", fontsize=10)

fig.tight_layout()
fig.savefig("/home/sahacloud/Downloads/images/ventas.png", bbox_inches="tight")
```

`dpi=160` y `bbox_inches="tight"` son la diferencia entre un gráfico presentable y uno pixelado con márgenes raros.

## Qué gráfico usar

| Pregunta que responde | Gráfico |
|---|---|
| Comparar categorías | Barras |
| Evolución en el tiempo | Líneas |
| Relación entre dos variables | Dispersión |
| Distribución de una variable | Histograma o caja |
| Composición del total | Barras apiladas |
| Correlación entre muchas variables | Mapa de calor |

**Tarta: solo con 2-4 categorías que sumen 100%.** Con más, el ojo humano no compara ángulos; usa barras horizontales.

## Recetas

**Líneas con varias series**
```python
ax.plot(x, serie_a, marker="o", label="2025", linewidth=2)
ax.plot(x, serie_b, marker="s", label="2026", linewidth=2)
ax.legend(frameon=False)
```

**Barras horizontales** — mejor cuando las etiquetas son largas
```python
ax.barh(categorias, valores, color="#4C78A8")
ax.invert_yaxis()          # el mayor arriba
```

**Histograma**
```python
ax.hist(datos, bins=20, color="#4C78A8", edgecolor="white")
```

**Mapa de calor**
```python
im = ax.imshow(matriz, cmap="RdYlBu_r", aspect="auto")
fig.colorbar(im, ax=ax)
ax.set_xticks(range(len(cols))); ax.set_xticklabels(cols, rotation=45, ha="right")
```

**Desde CSV**
```python
import pandas as pd
df = pd.read_csv("datos.csv")
fig, ax = plt.subplots(figsize=(9, 5), dpi=160)
df.groupby("categoria")["valor"].sum().plot(kind="bar", ax=ax, color="#4C78A8")
```

## Paleta legible

```python
COLORES = ["#4C78A8", "#F58518", "#54A24B", "#E45756", "#72B7B2", "#EECA3B"]
```
Distinguibles también para daltonismo rojo-verde. Evita rojo y verde como única diferencia entre series.

## Honestidad del gráfico

- **El eje Y de las barras empieza en cero.** Recortarlo exagera diferencias y es engañoso. En líneas sí puede recortarse, pero dilo.
- No uses 3D. Distorsiona la percepción de tamaño sin aportar nada.
- Etiqueta los ejes con **unidades**. "Ventas" no dice nada; "Ventas (miles de €)" sí.
- Si excluyes datos atípicos, indícalo en el pie.

## Verificación

```bash
imgqc ~/Downloads/images/ventas.png --min-mp 0.5
```

Nota: en gráficos con fondo blanco, `imgqc` avisará de "altas luces quemadas" y "pocos niveles de luminancia". **Es un falso positivo** — sus heurísticas están pensadas para fotografía. En un gráfico ignóralos; lo que sí importa es la resolución.

Lo que hay que comprobar mirando: que los valores dibujados coinciden con los datos de origen, que las etiquetas no se solapan y que la leyenda no tapa datos.

## Complementarios

`/baoyu-infographic` para infografía editorial, `/excalidraw` para esquemas a mano alzada, `/imagen-tecnica` para diagramas con estructura.
