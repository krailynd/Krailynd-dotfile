---
name: imagen-postproceso
description: "Mejorar imágenes ya existentes o recién generadas: ampliar resolución, corregir color y contraste, afilar, recortar a proporción y ampliar lienzo. Usa el comando `imgfx` (Pillow, sin GPU). Aplicar SIEMPRE después de generar, antes de entregar."
version: 1.0.0
author: sahacloud
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [Postproceso, Upscale, Color, Nitidez, Recorte, Pillow]
prerequisites:
  commands: [imgfx]
---

# /imagen-postproceso

`imgfx` (`~/.local/share/hermes/tools/imgfx`). Pillow, sin torch ni GPU.

## Lo normal: el pipeline

```bash
imgfx pipeline salida.png --factor 2
```
Hace en un paso: ampliar x2 (LANCZOS + máscara de enfoque) → autocontraste conservador → nitidez. Cubre el 90% de los casos.

Nunca sobrescribe: escribe `salida_pipeline.png`.

## Comandos

| Comando | Para qué |
|---|---|
| `imgfx info FOTO` | Diagnóstico: resolución, brillo, contraste, nitidez |
| `imgfx upscale FOTO --factor 2` | Ampliar con LANCZOS + unsharp |
| `imgfx color FOTO --auto --sat 1.15` | Contraste automático, saturación, calidez |
| `imgfx sharpen FOTO --amount 1.4` | Solo nitidez |
| `imgfx crop FOTO --ratio 16:9` | Recorte centrado a proporción |
| `imgfx pad FOTO --ratio 1:1 --color white` | Ampliar lienzo sin recortar nada |

Acepta un archivo **o un directorio** (procesa todas).

## Diagnosticar primero

```bash
imgfx info foto.png
```
```
foto.png
  400x300 (0.1 MP)  modo=RGB  1KB
  brillo medio 112/255   contraste (desv) 19
  nitidez de bordes 47.5  correcta
  AVISO: por debajo de 1 MP. Escasa para impresion o pantalla grande.
```
Con esto decides: si la nitidez es baja, `sharpen`; si es pequeña, `upscale`; si está apagada, `color --auto`.

## Color

```bash
imgfx color foto.png --auto                    # autocontraste, respeta el tono
imgfx color foto.png --sat 1.2 --contrast 1.1  # más vivo
imgfx color foto.png --warm 0.5                # más cálido (negativo = más frío)
imgfx color foto.png --bright 1.15             # más claro
```

`--auto` recorta un 0.5% por extremo con `preserve_tone`: recupera contraste sin virar los colores. Es lo primero que hay que probar.

Con moderación: `--sat 1.15` mejora, `--sat 1.8` da colores de plástico.

## Proporción: recortar o rellenar

```bash
imgfx crop miniatura.png --ratio 16:9      # recorta lo que sobra (pierde bordes)
imgfx pad  producto.png --ratio 1:1        # añade lienzo (conserva todo)
```

`crop` para miniaturas y cabeceras donde importa el encuadre. `pad` para catálogo o cuando no puedes perder nada de la imagen.

## Límites reales de esta máquina

- **No hay GPU.** Real-ESRGAN, GFPGAN y todo lo que necesite torch no funciona aquí. LANCZOS + unsharp es lo mejor disponible, y para ampliar x2 el resultado es perfectamente presentable.
- Tope de 40 megapíxeles por seguridad: con ~1.6 GB de RAM libre, una imagen mayor tumba el proceso. Si lo excedes, baja `--factor`.
- **Ampliar no inventa detalle.** x2 de una imagen nítida da un buen resultado; x8 de una borrosa da una borrosa grande. Si el original es malo, regenera a mayor resolución en vez de ampliar.

## Pixel art: no uses esto

`imgfx upscale` usa LANCZOS y **emborrona el pixel art**. Para sprites:
```bash
imgpx scale sprite.png --factor 8      # NEAREST, bordes perfectos
```
Ver `/imagen-pixelart`.

## Orden correcto

```
generar  →  imgqc  →  imgfx pipeline  →  imgqc otra vez  →  entregar
```
Verificar después de corregir, no solo antes.
