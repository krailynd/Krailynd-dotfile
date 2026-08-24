---
name: imagen-pixelart
description: "Pixel art y arte retro estilo Aseprite: sprites, tilesets, fondos y personajes con paletas históricas (NES, Game Boy, PICO-8, C64). Cubre el escalado sin desenfoque —el fallo que arruina el 90% del pixel art— cuantización de paleta, dithering y hojas de sprites. Usar para todo lo que sea pixel art, 8/16 bits o estética retro."
version: 1.0.0
author: sahacloud
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [PixelArt, Aseprite, Retro, Sprites, NES, GameBoy, PICO8, Paletas]
prerequisites:
  commands: [imgpx]
---

# /imagen-pixelart

## La regla que lo cambia todo

**El pixel art se escala con vecino más próximo (NEAREST), nunca con interpolación.**

Cualquier redimensionado suave (LANCZOS, bicúbico, bilineal) mezcla los píxeles y destruye el estilo: el resultado se ve borroso y "sucio". Es el fallo más común y el más fácil de evitar.

```bash
imgpx scale sprite.png --factor 8      # NEAREST, bordes perfectos
```

Nunca uses `imgfx upscale` con pixel art — usa LANCZOS y lo emborrona. `imgfx` es para fotografía.

## Alta resolución de verdad

"Pixel art en alta resolución" no significa un sprite de 32x32 estirado. Hay dos caminos y son distintos:

1. **Más detalle**: dibuja el lienzo grande de origen (128x128 o 256x256) y escala x2-x4. Más píxeles reales, más detalle.
2. **Mismo estilo, más grande**: lienzo pequeño (32x32) escalado x8-x16. Píxeles enormes y nítidos, estética clásica.

Decide cuál quieres antes de generar. Un sprite de 32x32 nunca tendrá el detalle de uno de 128x128, por mucho que lo amplíes.

## Generar con IA y convertir

Los modelos no producen pixel art auténtico: dan una imagen "con aspecto de" píxeles, con miles de colores y bordes irregulares. El flujo correcto es generar y **cuantizar**:

```bash
# 1. generar (modelo barato basta: el detalle fino se pierde al cuantizar)
#    prompt: "16-bit pixel art sprite of a knight, side view, transparent background,
#             limited palette, clean pixel edges, no anti-aliasing"

# 2. convertir a pixel art real
imgpx pixelate knight.png --size 64 --colors 16

# 3. escalar para verlo
imgpx scale knight_px.png --factor 8
```

`pixelate` reduce a la rejilla real y cuantiza la paleta — eso convierte una imagen "estilo píxel" en píxel de verdad.

Ya instalados y complementarios: `/pixel-art` y `/ai-to-pixel-art`.

## Paletas históricas

```bash
imgpx palette sprite.png --preset gameboy
imgpx palette sprite.png --preset nes
imgpx palette sprite.png --preset pico8
imgpx palette sprite.png --preset c64
imgpx palette sprite.png --preset cga
```

| Paleta | Colores | Estética |
|---|---|---|
| `gameboy` | 4 verdes | Portátil 1989, nostálgico |
| `nes` | 54 | Consola 8 bits clásica |
| `pico8` | 16 | Fantasy console moderna, muy legible |
| `c64` | 16 | Microordenador, tonos apagados |
| `cga` | 4 | PC 1981, cian/magenta agresivo |

Restringir la paleta es lo que hace que "parezca" retro. Con 16 colores bien elegidos se ve más auténtico que con 4000.

## Hojas de sprites

```bash
imgpx sheet ~/sprites/caminar/ --cols 4        # une frames en una hoja
imgpx split hoja.png --cols 4 --rows 2         # separa una hoja en frames
```

Convención de nombres para que el orden salga bien: `walk_000.png`, `walk_001.png`…

## Prompts que funcionan

```
16-bit pixel art sprite of a [sujeto], side view, transparent background,
limited color palette, clean pixel edges, no anti-aliasing, no gradients
```

```
pixel art background of a [lugar], 16-bit era, parallax layers,
limited palette, dithering for shading, crisp pixels
```

Palabras clave que importan: `no anti-aliasing`, `clean pixel edges`, `limited palette`. Sin ellas el modelo devuelve una ilustración suave.

Añadir `dithering` da el sombreado punteado característico de la época.

## Fondo transparente

Los modelos rara vez dan transparencia real. Después:
```bash
imgpx alpha sprite.png --key "#00FF00"    # quita el color de fondo
```
Genera con fondo verde o magenta plano (`solid green background`) y recórtalo por color.

## Cierre

Mira el sprite **al 100% y escalado**. Fallos típicos: píxeles huérfanos sueltos, bordes con medio tono (anti-aliasing residual), y colores fuera de paleta. `imgpx palette` los limpia de golpe.

Aseprite no está instalado (requiere `snap` con sudo, y aquí no hay sudo sin contraseña). `imgpx` cubre el flujo completo sin él.
