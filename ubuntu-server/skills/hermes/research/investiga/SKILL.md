---
name: investiga
description: "Enrutador de investigación web. Detecta el tipo de fuente (Reddit, X, YouTube, web genérica), elige el método correcto (API oficial, MCP, extracción HTTP o navegador), normaliza el resultado a un esquema único, descarga media cuando procede y devuelve SIEMPRE el permalink original. Punto de entrada para leer posts, hilos, artículos o procesar muchos enlaces de golpe."
version: 1.0.0
author: sahacloud
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [Investigacion, Scraping, Reddit, X, Extraccion, Media, Permalink]
prerequisites:
  commands: [websrc]
---

# /investiga

Punto de entrada único para leer contenido de la web. El comando es `websrc`.

## Uso

```bash
websrc fetch URL                 # extraer y normalizar
websrc fetch URL --media         # además descargar imágenes y vídeo
websrc fetch URL1 URL2 URL3      # varias de golpe
websrc batch enlaces.txt         # una URL por línea
websrc list                      # qué hay ya extraído
websrc show URL                  # JSON completo de un item
websrc errors                    # últimos fallos
```

Almacén: `~/.hermes/websrc/` — `items/<hash>.json`, `media/`, `errors.log`.

## Esquema normalizado

**Toda** fuente devuelve la misma estructura. El agente no tiene que adivinar el formato según el sitio:

```json
{
  "url": "...", "fuente": "reddit|x|youtube|web", "metodo": "praw|http+opengraph|...",
  "titulo": null, "autor": null, "fecha": null, "texto": null,
  "metricas": {}, "media": [], "enlaces": [], "comentarios": [],
  "permalink": "...", "extra": {}
}
```

**Devuelve siempre el `permalink` en la respuesta al chat.** Es el requisito no negociable: el usuario tiene que poder ir a la fuente original.

## Enrutado por fuente

| Fuente detectada | Método | Estado |
|---|---|---|
| Reddit | PRAW (API oficial OAuth) | Operativo con credenciales — ver `/reddit-reader` |
| X / Twitter | API oficial (`xurl`), yt-dlp para media, navegador con sesión | Ver `/x-lector` — limitado |
| YouTube | yt-dlp | Operativo |
| Web genérica | HTTP + Open Graph + JSON-LD | Operativo, sin credenciales |
| Búsqueda | `/websearch-local` (SearXNG propio) | Operativo, gratis |

La clasificación es automática por dominio. No hace falta indicarla.

## Robustez — lo que ya hace

- **Reintento con espera exponencial** en fallos de red.
- **Respeta `Retry-After`** en HTTP 429 en vez de martillear el servidor.
- **No reintenta 4xx** (salvo 429): un 403 o 404 no se arregla repitiendo.
- **Deduplica por URL**: si ya se extrajo, lo lee de caché. `--force` para rehacer.
- **Registra errores** en `errors.log` con etapa y excepción; consulta con `websrc errors`.
- **No se rompe si una fuente falla**: en un lote, las demás siguen.
- **Verifica `Content-Type`** antes de guardar una imagen.

## Media

```bash
websrc fetch URL --media
```
Vídeo por `yt-dlp` (conoce Reddit, X y YouTube); imágenes por descarga directa con verificación de tipo. Van a `~/.hermes/websrc/media/<hash>/`.

Si no se puede descargar, el item conserva la **URL del archivo** y el **permalink del post**. Nunca se pierde la referencia.

## Procesar muchos enlaces

```bash
printf '%s\n' url1 url2 url3 > /tmp/lote.txt
websrc batch /tmp/lote.txt --media
```
Secuencial a propósito: el paralelismo agresivo es lo que dispara los bloqueos por rate limit. Si son cientos de URLs, trocea en lotes y espacia las ejecuciones.

## Contenido dinámico y scroll infinito

`websrc` hace HTTP plano: no ejecuta JavaScript. Para páginas que cargan por scroll o requieren interacción, usa el **Playwright MCP** (ya activo en `localhost:8931`) o el skill `/browser-use`, y pasa después las URLs concretas a `websrc` para normalizar.

División de trabajo: navegador para **descubrir** URLs, `websrc` para **extraer** de cada una.

## Límites de uso

- Respeta `robots.txt` y los términos del sitio.
- No paralelices para saltar rate limits — el reintento con espera ya está puesto por algo.
- Contenido con derechos: descarga para uso propio, no republiques sin permiso.
- Si un sitio pide sesión, usa credenciales propias del usuario; no intentes evadir el muro.

## Skills relacionados

`/reddit-reader`, `/x-lector`, `/websearch-local`, `/browser-use`, `/scrapling`, `/firecrawl-search`, `/notebooklm`.
