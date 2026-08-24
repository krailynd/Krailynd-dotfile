---
name: imagen
description: Generación universal de imágenes por IA gratis e ilimitada (Flux.1 / SDXL / Realismo / Anime) con local-image-gen.py.
---

# Generación Universal de Imágenes (IA Gratis e Ilimitada)

Skill maestra para generar imágenes artísticas, retratos, paisajes, escenas y anime sin costo ni límites de API key.

## MOTOR EJECUTABLE
Usar la herramienta `local-image-gen.py` (`~/.local/bin/local-image-gen.py`):

```bash
python3 ~/.local/bin/local-image-gen.py --prompt "Prompt descriptivo en inglés..." --out /ruta/destino.png --model <modelo> --width <ancho> --height <alto>
```

### OPCIONES DE MODELO (`--model`):
- `flux` -> Alta calidad y detalle general (por defecto).
- `flux-realism` -> Fotorrealismo cinemático.
- `flux-anime` -> Estilo Anime / Manga / Ilustración.
- `flux-3d` -> Renders 3D / CGI.
- `turbo` -> Generación ultrarrápida.
