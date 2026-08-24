---
name: frame-video
description: "Convertir secuencias de imágenes en vídeo con FFmpeg, y producir esas secuencias manteniendo coherencia de personaje, fondo y estilo entre fotogramas. Cubre montaje a 24/30/60 fps, interpolación para suavizar movimiento, GIF, y recorte/unión de vídeo. Usar cuando se pida animación, vídeo corto o secuencia visual."
version: 1.0.0
author: sahacloud
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [Video, Frames, FFmpeg, Animacion, GIF, Secuencias]
prerequisites:
  commands: [ffmpeg]
---

# /frame-video

ffmpeg está instalado. **No hay generación de vídeo por IA disponible aquí**: no hay GPU y no hay clave de ningún servicio de vídeo configurada. El camino es generar fotogramas como imágenes y montarlos.

## Montar fotogramas a vídeo

Nombres numerados consecutivos: `frame_0000.png`, `frame_0001.png`…

```bash
ffmpeg -framerate 24 -i frame_%04d.png \
  -c:v libx264 -pix_fmt yuv420p -crf 18 salida.mp4
```

- `-pix_fmt yuv420p` es **obligatorio** para que se vea en navegadores, WhatsApp y reproductores normales. Sin esto sale un vídeo que solo abre VLC.
- `-crf 18` calidad alta (rango 0-51; 23 es el defecto, menor = mejor).
- `-framerate` antes de `-i` fija los fps de **entrada**. Es el que manda.

## Cuántos fotogramas

| fps | Sensación | Fotogramas para 5 s |
|---|---|---|
| 12 | Animación tradicional, entrecortada | 60 |
| 24 | Cine, estándar | 120 |
| 30 | Vídeo, suave | 150 |
| 60 | Muy fluido, cámara lenta | 300 |

Generar 120 imágenes por API cuesta dinero real. **Calcula antes**: 120 fotogramas en `flux-2/klein/9b` a $0.006/MP ≈ un coste asumible; en `recraft/v4/pro` a $0.25/imagen son $30. Usa el modelo barato para secuencias.

Alternativa sensata: genera 12-24 fotogramas clave e **interpola**.

## Interpolar para suavizar

Convierte 12 fps en 60 sin generar más imágenes:

```bash
ffmpeg -i entrada.mp4 -filter:v "minterpolate=fps=60:mi_mode=mci" salida_suave.mp4
```
`mci` (motion-compensated interpolation) inventa fotogramas intermedios. Con movimiento suave funciona bien; con cambios bruscos produce artefactos. Míralo antes de entregar.

Más barato en cálculo, sin inventar movimiento:
```bash
ffmpeg -i entrada.mp4 -filter:v "minterpolate=fps=30:mi_mode=dup" salida.mp4
```

## Coherencia entre fotogramas

Es la parte difícil. Sin ControlNet ni IPAdapter (requieren GPU), el método es:

1. **Semilla fija en todos los fotogramas.** Sin esto, cada imagen es un mundo distinto.
2. **Bloque de descripción idéntico**, palabra por palabra. Guárdalo y pégalo:
   ```
   mujer de pelo castaño corto, chaqueta roja, fondo de calle urbana al atardecer
   ```
3. **Cambia una sola cosa por fotograma** — la pose, o la posición, no ambas.
4. **Encadena por referencia**: usa el fotograma anterior como `image_urls` en el `edit_endpoint` del modelo. Es lo que más ayuda a la continuidad.
5. **Movimiento pequeño entre fotogramas.** Saltos grandes rompen la ilusión.

Expectativa realista: con API se consigue una secuencia **reconocible y estilísticamente coherente**, no una animación de identidad perfecta. Para eso hace falta ComfyUI con GPU, que esta máquina no tiene. Dilo antes de empezar si el proyecto lo exige.

## Alternativa barata: animar una sola imagen

Muchas veces basta con movimiento de cámara sobre una imagen fija — cero coste de generación:

```bash
# zoom lento (efecto Ken Burns), 5 s a 30 fps
ffmpeg -loop 1 -i foto.png -vf \
  "zoompan=z='min(zoom+0.0008,1.3)':d=150:s=1920x1080,format=yuv420p" \
  -t 5 -c:v libx264 salida.mp4

# desplazamiento horizontal
ffmpeg -loop 1 -i panoramica.png -vf \
  "crop=1920:1080:x='(iw-1920)*t/5':y=0,format=yuv420p" \
  -t 5 -c:v libx264 paneo.mp4
```
Resultado profesional, una sola imagen generada.

## GIF

```bash
# paleta propia = colores muy superiores al GIF por defecto
ffmpeg -i salida.mp4 -vf "fps=12,scale=640:-1:flags=lanczos,palettegen" paleta.png
ffmpeg -i salida.mp4 -i paleta.png -lavfi "fps=12,scale=640:-1:flags=lanczos[x];[x][1:v]paletteuse" salida.gif
```
Sin el paso de paleta el GIF sale con bandas de color feas.

## Edición básica

```bash
# recortar sin recodificar (instantáneo)
ffmpeg -i entrada.mp4 -ss 00:00:10 -to 00:00:25 -c copy recorte.mp4

# unir (mismo códec)
printf "file '%s'\n" clip1.mp4 clip2.mp4 > lista.txt
ffmpeg -f concat -safe 0 -i lista.txt -c copy unido.mp4

# extraer fotogramas de un vídeo
ffmpeg -i entrada.mp4 -vf fps=2 frame_%04d.png

# quitar silencios
ffmpeg -i entrada.mp4 -af "silenceremove=stop_periods=-1:stop_duration=0.3:stop_threshold=-40dB" salida.mp4

# subtítulos incrustados
ffmpeg -i entrada.mp4 -vf "subtitles=subs.srt:force_style='FontSize=24'" subtitulado.mp4
```

## Antes de montar

```bash
imgqc ~/frames/ --min-mp 0.5      # revisa TODOS los fotogramas
```
Un fotograma borroso en medio de la secuencia salta a la vista al reproducir. Es más barato detectarlo antes de montar que después.

Y mira la secuencia completa: parpadeos de color, elementos que aparecen y desaparecen, saltos de posición.

## Complementarios

`/manim-video` (animación matemática, ya instalado), `/ascii-video`, `/imagen-postproceso` para preparar los fotogramas.
