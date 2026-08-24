---
name: image-gallery
description: "Organizar imágenes: listar con dimensiones, generar miniaturas, montar hojas de contacto, redimensionar en lote, convertir formatos y detectar duplicados por contenido. Usa el comando `imggal`, basado en Pillow — NO necesita ImageMagick ni sudo."
version: 1.0.0
author: sahacloud
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [Images, Pillow, Thumbnails, Collage, Dedupe, Media]
prerequisites:
  commands: [imggal]
---

# Image Gallery

Comando: `imggal` (`~/.local/share/hermes/tools/imggal`, symlink en `~/.local/bin/`). Pillow 12.3.0, ya instalado.

> Las guías que piden `sudo apt install imagemagick` y usan `convert`/`montage` **no aplican aquí**: esta máquina no tiene sudo sin contraseña ni ImageMagick. Pillow hace lo mismo sin instalar nada.

Directorio por defecto en todos los subcomandos: `~/Downloads/images`. Se puede pasar otro como primer argumento.

## Listar

```bash
imggal list
imggal list ~/otra/carpeta
```
```
test_0.png       800x600    RGB    3KB
test_1.png       1200x900   RGB    5KB

2 archivo(s), 8KB
```

## Miniaturas

```bash
imggal thumbs --size 200
```
Escribe JPEG en `DIR/thumbnails/`. No toca los originales.

## Hoja de contacto

```bash
imggal sheet --cols 4 --cell 200
```
Genera `DIR/contact_sheet.jpg` con todo en rejilla. Útil para revisar de un vistazo qué se descargó.

## Redimensionar en lote

```bash
imggal resize --max 1920
```
**Modifica in-place**, solo las que exceden el máximo (respeta proporción). Las más pequeñas no se tocan y no pierden calidad.

Aviso: sobrescribe los originales. Haz copia antes si los necesitas intactos.

## Convertir formato

```bash
imggal convert --to webp
imggal convert --to jpg
```
Crea el archivo nuevo junto al original; **no borra el viejo**. Formatos: jpg, png, webp.

## Duplicados

```bash
imggal dedupe
```
Agrupa por hash SHA-256 del contenido — detecta copias aunque tengan otro nombre.

```
duplicado: test_0.png
    == test_dup.png

1 grupo(s), 3KB recuperables. Borrado NO automatico: revisa y borra tu.
```

**No borra nada.** Solo informa. El borrado es decisión del usuario.

## Formatos soportados

`.jpg .jpeg .png .gif .webp .bmp .avif .tiff`

**`.svg` no**: es vectorial y Pillow no lo abre. Los SVG que baje `/image-downloader` se ignoran aquí sin error.

## Flujo típico

```bash
imgdl --page 'https://ejemplo.com/galeria' --max 30 --min-bytes 20000
imggal list
imggal dedupe
imggal resize --max 1920
imggal sheet --cols 5
```
