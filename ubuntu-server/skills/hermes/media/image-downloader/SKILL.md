---
name: image-downloader
description: "Descargar imágenes: una URL directa, o todas las imágenes de una página web. Usa el comando `imgdl`, que parsea el HTML de verdad (img, source, srcset, lazy-load y background-image de CSS), verifica el Content-Type antes de guardar, descarta iconos por tamaño mínimo y nombra los archivos con hash para no duplicar. Destino por defecto ~/Downloads/images/."
version: 1.0.0
author: sahacloud
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [Images, Download, Scraping, Media]
prerequisites:
  commands: [imgdl]
---

# Image Downloader

Comando: `imgdl` (`~/.local/share/hermes/tools/imgdl`, symlink en `~/.local/bin/`). Solo stdlib de Python, sin dependencias.

## Una imagen

```bash
imgdl 'https://ejemplo.com/foto.jpg'
```

## Todas las de una página

```bash
imgdl --page 'https://ejemplo.com/galeria' --max 20
```

**Entrecomilla siempre la URL.** En zsh, un paréntesis sin comillas rompe el comando:
`zsh: no matches found: https://...Java_(programming_language)`

## Opciones

| Opción | Efecto |
|---|---|
| `--page` | Trata la URL como página y baja sus imágenes |
| `--max N` | Tope de descargas (por defecto 20) |
| `--min-bytes N` | Descarta menores de N bytes — quita iconos y píxeles de tracking |
| `--out DIR` | Destino distinto de `~/Downloads/images/` |

Filtrar miniaturas e iconos:
```bash
imgdl --page 'https://ejemplo.com' --max 30 --min-bytes 20000
```

## Qué hace bien

- Parser HTML real, no regex: coge `<img src>`, `data-src`, `data-lazy-src`, `<source srcset>` y `background-image:url()` de CSS.
- Resuelve rutas relativas contra la URL de la página.
- **Verifica `Content-Type` antes de guardar** — no guarda un HTML de error con extensión `.jpg`.
- Extensión según el MIME real, no según la URL.
- Nombre `host_indice_hash8.ext`: sin colisiones y trazable al origen.
- Salta las que ya existen (mismo hash de contenido).

## Limitaciones

- Imágenes cargadas por JavaScript después del render no aparecen en el HTML. Para eso usa `/browser-use`.
- No baja `data:` URIs embebidas.
- Los `.svg` se descargan bien, pero `/image-gallery` no los procesa (Pillow no abre SVG).

## Ejemplo real

```
$ imgdl --page 'https://en.wikipedia.org/wiki/Java_(programming_language)' --max 4 --min-bytes 5000
encontradas 47 candidatas; bajando hasta 4
destino: /home/sahacloud/Downloads/images
  en-wikipedia-org_000_095fb188.svg  (115,918 B)
  en-wikipedia-org_001_169241ae.svg  (9,865 B)
  en-wikipedia-org_002_400508c0.svg  (15,219 B)
  omitida (703 B < 5000): .../Semi-protection-shackle.svg

3 imagen(es) descargada(s)
```

## Después de descargar

`/image-gallery` para listar, miniaturas, hoja de contacto, redimensionar o buscar duplicados.

## Respeto

Descarga solo lo que tengas derecho a usar. Comprueba licencia y `robots.txt` antes de un scrape masivo.
