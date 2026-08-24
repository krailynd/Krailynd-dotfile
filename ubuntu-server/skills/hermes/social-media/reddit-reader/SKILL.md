---
name: reddit-reader
description: "Leer Reddit con la API oficial vía PRAW: posts, comentarios, subreddits, tendencias, imágenes y vídeos. Extrae título, autor, subreddit, fecha, score, número de comentarios, permalink, contenido, media adjunta, comentarios relevantes y URLs externas citadas en el hilo. Requiere credenciales de app 'script' — el acceso anónimo por .json devuelve 403 desde el cierre de la API de Reddit."
version: 2.0.0
author: sahacloud
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [Reddit, PRAW, Comentarios, Subreddit, Media, OAuth]
prerequisites:
  commands: [websrc]
---

# Reddit — vía PRAW

`praw 8.0.2` instalado en el venv de Hermes.

## Lo que NO funciona

```bash
curl -H "User-Agent: X" "https://www.reddit.com/r/java/hot.json"
```
**HTTP 403.** Comprobado con User-Agent propio y de navegador, en `www` y `old`. Reddit cerró el acceso anónimo. Si una guía dice "Reddit sin auth", está desactualizada. No pierdas intentos cambiando cabeceras.

## Configuración — 3 minutos, gratis

1. https://www.reddit.com/prefs/apps → **create app** → tipo **script**
2. En `~/.hermes/.env` (los placeholders ya están):
```
REDDIT_CLIENT_ID=...
REDDIT_CLIENT_SECRET=...
REDDIT_USER_AGENT=hermes/1.0 by /u/tu_usuario
```
El `user_agent` con tu usuario real no es opcional: Reddit limita más agresivamente a los genéricos.

## Uso normal

```bash
websrc fetch 'https://www.reddit.com/r/java/comments/ID/titulo/' --media
```

Devuelve, normalizado:

| Campo | Contenido |
|---|---|
| `titulo` | Título del post |
| `autor` | Autor (`[borrado]` si se eliminó) |
| `fecha` | ISO 8601 UTC |
| `texto` | Cuerpo del post (selftext) |
| `metricas` | `score`, `ratio_votos`, `comentarios` |
| `extra.subreddit` | Subreddit |
| `extra.nsfw` | Marcado NSFW |
| `media` | Imágenes, vídeo o galería |
| `comentarios` | Top 15 con autor, score y texto |
| `enlaces` | URLs externas del post y de los comentarios |
| **`permalink`** | **URL canónica — devuélvela siempre al chat** |

## Media

`--media` descarga a `~/.hermes/websrc/media/<hash>/`:
- **Vídeo** (`v.redd.it`) por `yt-dlp`. Reddit sirve vídeo y audio en pistas separadas; yt-dlp las une, un `curl` no.
- **Imágenes** (`i.redd.it`, galerías) por descarga directa con verificación de `Content-Type`.

Si algo no se puede bajar, el item conserva la URL del archivo y el permalink. Nunca se pierde la referencia.

## Consultas más allá de un post

Para listados, búsqueda y tendencias, PRAW directo:

```python
import praw, os
r = praw.Reddit(client_id=os.environ["REDDIT_CLIENT_ID"],
                client_secret=os.environ["REDDIT_CLIENT_SECRET"],
                user_agent=os.environ["REDDIT_USER_AGENT"])
r.read_only = True

for p in r.subreddit("java").hot(limit=10):
    print(p.score, p.title, f"https://reddit.com{p.permalink}")

for p in r.subreddit("all").search("spring boot 4", sort="new", limit=10):
    print(p.subreddit, p.title)

for p in r.subreddit("java").top(time_filter="week", limit=5):
    print(p.score, p.title)
```
Intérprete: `~/.hermes/hermes-agent/venv/bin/python` (praw no está en el Python del sistema).

Listados útiles: `.hot()`, `.new()`, `.top(time_filter=...)`, `.rising()`, `.controversial()`.
`time_filter`: `hour`, `day`, `week`, `month`, `year`, `all`.

## Comentarios en profundidad

```python
post.comments.replace_more(limit=0)      # 0 = no expandir "cargar mas"
for c in post.comments.list()[:50]:
    print(c.score, c.author, c.body[:200])
```
`replace_more(limit=None)` expande el árbol entero: en hilos grandes son cientos de peticiones y te comes el rate limit. Empieza con `limit=0`.

## Límites de uso

- 100 peticiones/minuto con `client_credentials`. PRAW las cuenta y espera solo.
- `read_only = True` salvo que de verdad haya que publicar.
- No paralelices para saltarte el límite: te ganas un bloqueo del client_id.
- Contenido de Reddit tiene autor y derechos: cita el permalink, no republiques como propio.

## Sin credenciales

`websrc` lo detecta y avisa en `extra.aviso` en vez de fallar en silencio. Alternativa mientras tanto: `/websearch-local` con `site:reddit.com` — da títulos y URLs, no el hilo completo.
