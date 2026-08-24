---
name: pixel-art
description: "Use when converting a photo or image into pixel art, creating sprites, character portraits, comic panels or backgrounds in retro style, applying Game Boy / NES / PICO-8 palettes, or when the user attaches an image and asks for a pixelated, retro or 8-bit version of it."
license: MIT
compatibility: "Hermes Agent v0.19.0+. Requiere el venv propio del skill (Pillow). No usa red ni IA generativa."
metadata:
  author: auditoria-hermes-20260721
  version: "1.0.0"
---

# Pixel art determinista

Convierte una imagen existente en pixel art **sin IA generativa**. El resultado
es reproducible: misma entrada y mismos parametros producen el mismo archivo.

Para *generar* una imagen desde cero (texto → imagen) esto no sirve; ver
`IMAGE_CAPABILITIES.md` en `ops/hermes-optimization-20260721/`.

## Invocacion

Usa **siempre** el interprete del venv del skill. El del sistema no tiene Pillow
y no debe modificarse (PEP 668):

```bash
SKILL=~/.hermes/skills/creative/pixel-art
$SKILL/.venv/bin/python $SKILL/scripts/pixelart.py ENTRADA SALIDA [opciones]
```

## Presets

| Preset | Resolucion logica | Escala | Salida tipica | Para |
|---|---:|---:|---|---|
| `sprite` | 32 px | 12x | 384x288 | sprite de personaje u objeto |
| `portrait` | 64 px | 8x | 512x384 | retrato / cara |
| `comic-panel` | 96 px | 6x | 576x432 | viñeta de comic |
| `background` | 128 px | 5x | 640x480 | fondo o escenario |

"Resolucion logica" es el lado mayor en pixeles reales antes de ampliar. La
escala solo agranda cada pixel; no añade detalle.

## Paletas

| Paleta | Colores | Aspecto |
|---|---:|---|
| `gameboy` | 4 | verdes de Game Boy DMG |
| `nes` | 16 | subconjunto de la NTSC 2C02 |
| `pico8` | 16 | paleta de la fantasy console PICO-8 |
| `adaptive` | 2–64 | derivada de la propia imagen (`--colors`) |

`adaptive` es la mas fiel al original; las fijas dan el look retro reconocible.

## Ejemplos

```bash
SKILL=~/.hermes/skills/creative/pixel-art
PY=$SKILL/.venv/bin/python
S=$SKILL/scripts/pixelart.py

# Sprite en Game Boy
$PY $S foto.jpg sprite.png --preset sprite --palette gameboy

# Retrato PICO-8 con difuminado
$PY $S retrato.png out.png --preset portrait --palette pico8 --dither

# Control manual
$PY $S imagen.webp out.png --resolution 48 --scale 10 --palette adaptive --colors 12

# Ver paletas y presets
$PY $S --list-palettes
```

## Garantias

- **Nunca sobrescribe el original.** Si entrada y salida coinciden, aborta.
- Respeta la orientacion EXIF (las fotos de movil no salen giradas).
- Conserva la transparencia y la binariza (0 o 255): el pixel art no admite
  bordes semitransparentes.
- Reescalado final con `NEAREST`, que es lo que produce el borde duro. La
  reduccion previa usa `BOX` (promedio por bloque), correcto al reducir.
- Salida siempre PNG.

## Limites y errores

Rechaza con mensaje claro y codigo != 0:

- archivo inexistente, ilegible o que no es una imagen
- formato distinto de PNG / JPEG / WebP
- entrada mayor de 40 MP (proteccion frente a bombas de descompresion)
- `--resolution` fuera de 8–512, `--scale` fuera de 1–32, `--colors` fuera de 2–64
- salida cuyo lado mayor superaria 4096 px
- entrada y salida iguales

## Instalacion (una sola vez)

```bash
SKILL=~/.hermes/skills/creative/pixel-art
python3 -m venv $SKILL/.venv
$SKILL/.venv/bin/pip install Pillow
```

**No uses `pip install --break-system-packages`.** Ubuntu marca su Python como
gestionado externamente (PEP 668) y hacerlo puede romper paquetes del sistema.
El venv aislado es la via correcta y no toca nada fuera del directorio del skill.

Dependencias: solo Pillow. **NumPy no hace falta** y no esta instalado.

## Pruebas

```bash
SKILL=~/.hermes/skills/creative/pixel-art
$SKILL/.venv/bin/python $SKILL/scripts/test_pixelart.py
```

21 comprobaciones con imagenes sinteticas (sin red, sin imagenes reales).
Verifican lo que de verdad distingue el pixel art de una imagen reducida:

- la paleta de salida esta acotada al numero de colores pedido
- **los bloques de `scale x scale` son planos en >= 99%** — la prueba objetiva
  del borde duro; con un filtro suavizante esta cifra se desploma
- la transparencia sobrevive y queda binarizada
- el original conserva mtime y bytes intactos
- cada modo de error produce mensaje util y codigo distinto de cero

Estado a 2026-07-21: **21 correctas, 0 fallidas** (Pillow 12.3.0).
