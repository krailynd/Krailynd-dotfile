---
name: imagen-verifica
description: Skill de inspección y visión técnica de imágenes sin fallos de API key (local-vision-ocr.py + Pillow + OCR Tesseract).
---

# Inspección y Visión Técnica de Imágenes

Skill para analizar cualquier imagen visualmente, extraer dimensiones, paleta de colores dominantes RGB, luminancia, contraste y texto OCR.

## MOTOR EJECUTABLE
Usar la herramienta `local-vision-ocr.py` (`~/.local/bin/local-vision-ocr.py`):

```bash
python3 ~/.local/bin/local-vision-ocr.py /ruta/imagen.png
```

### PROPIEDADES EXTRAÍDAS:
1. **Dimensiones & Aspect Ratio**: Resolución exacta y orientación (landscape / portrait / square).
2. **Colores Dominantes**: Paleta de 5 colores principales en formato RGB(R,G,B).
3. **Luminancia & Contraste**: Calidad de iluminación y rango dinámico.
4. **Texto OCR**: Extracción de texto e inscripciones con Tesseract 5.5.
