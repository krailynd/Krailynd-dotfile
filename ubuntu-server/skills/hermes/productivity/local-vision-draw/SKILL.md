---
name: local-vision-draw
description: Skill de Generación de Imágenes por IA Gratis e Ilimitada (Flux.1 / Pollinations) y Visión por Computadora (OCR + Análisis Técnico Visual).
---

# Local Vision & Free AI Draw Skill

Skill para generar imágenes artísticas por IA (Gratis, ilimitado, sin API key) y analizar imágenes mediante OCR y visión técnica local.

---

## 1. GENERACIÓN DE IMÁGENES CON IA (GRATIS E ILIMITADO)

Usa la herramienta `local-image-gen.py`:

```bash
python3 ~/.local/bin/local-image-gen.py --prompt "Prompt detallado en inglés..." --out /ruta/imagen.png --model flux
```

### Modelos Disponibles:
- `flux` -> Alta calidad general (por defecto).
- `flux-realism` -> Fotorrealismo.
- `flux-anime` -> Estilo Anime / Ilustración.
- `flux-3d` -> Renders 3D.
- `turbo` -> Generación ultrarrápida.

---

## 2. ANÁLISIS DE IMÁGENES Y VISIÓN

Usa la herramienta `local-vision-ocr.py`:

```bash
python3 ~/.local/bin/local-vision-ocr.py /ruta/imagen.png
```

Extrae:
- Dimensiones, aspect ratio y orientación.
- Paleta de 5 colores dominantes (RGB).
- Niveles de luminancia y contraste.
- Texto incrustado vía OCR (Tesseract en español e inglés).
