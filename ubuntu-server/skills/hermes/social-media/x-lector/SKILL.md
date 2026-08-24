---
name: x-lector
description: "Leer publicaciones, hilos, media y respuestas de X (Twitter): texto, autor, fecha, métricas visibles, media adjunta, enlaces, contexto del hilo y URL del post. Documenta las tres vías reales —API oficial vía xurl, yt-dlp para media pública, y navegador con sesión— y cuál usar en cada caso, porque X no sirve contenido a clientes sin sesión."
version: 1.0.0
author: sahacloud
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [X, Twitter, Hilos, Media, xurl, ytdlp, Playwright]
---

# X (Twitter)

## El hecho que ordena todo lo demás

**X no sirve contenido a clientes sin sesión.** Comprobado el 2026-07-22: `websrc fetch` sobre un post de X devuelve Open Graph vacío — ni título, ni texto, ni autor. Los endpoints públicos de scraping que circulan en guías llevan años sin funcionar.

Hay tres vías reales. Úsalas en este orden.

---

## Vía 1 — API oficial con `xurl` (la buena)

El skill `/xurl` ya está instalado y habla con la API oficial de X. Es la única vía estable, la única permitida por los términos de X, y la única que no arriesga tu cuenta.

```bash
xurl /2/tweets/ID?tweet.fields=created_at,public_metrics,author_id,entities
xurl /2/tweets/ID?expansions=attachments.media_keys\&media.fields=url,preview_image_url,type
xurl /2/users/by/username/NOMBRE
```

Da: texto, autor, fecha, métricas públicas (likes, reposts, respuestas, vistas), entidades (enlaces, menciones, hashtags) y claves de media.

**Limitación real:** el plan gratuito de la API de X es muy restrictivo en lecturas mensuales. Para volumen hace falta plan de pago. Es el precio de la vía estable.

Configura credenciales siguiendo `/xurl`.

## Vía 2 — `yt-dlp` para media pública

Funciona **sin credenciales** para posts públicos con vídeo. Verificado: yt-dlp alcanza X y parsea el post (en un post sin vídeo responde `No video could be found in this tweet`, que es la respuesta correcta, no un bloqueo).

```bash
yt-dlp 'https://x.com/USUARIO/status/ID'                    # descargar vídeo
yt-dlp --skip-download --dump-json 'https://x.com/.../status/ID'   # solo metadatos
yt-dlp --write-thumbnail --skip-download 'https://x.com/.../status/ID'
```

Integrado en el flujo normal:
```bash
websrc fetch 'https://x.com/USUARIO/status/ID' --media
```

Para posts protegidos o que exigen sesión, yt-dlp acepta cookies del navegador:
```bash
yt-dlp --cookies-from-browser chromium 'https://x.com/.../status/ID'
```

## Vía 3 — navegador con sesión (último recurso)

Playwright MCP está activo en `localhost:8931`; también está `/browser-use`. Permite leer hilos completos, respuestas y contenido que carga por scroll.

Antes de usarla, ten claro esto:

- **Los términos de X prohíben el scraping automatizado.** Usarla es decisión del usuario, no un tecnicismo que se pueda ignorar.
- **Automatizar una sesión con login real puede acabar en suspensión de la cuenta.** X detecta patrones de automatización.
- Es frágil: X cambia el DOM a menudo y los selectores se rompen sin aviso.

Si el usuario decide seguir: ritmo humano (pausas de segundos, no milisegundos), volumen bajo, sesión propia, y nunca para recolección masiva. Si el objetivo es volumen, la respuesta correcta es la API de pago, no un scraper más agresivo.

---

## Qué extraer de un post

| Campo | Vía 1 (API) | Vía 2 (yt-dlp) | Vía 3 (navegador) |
|---|---|---|---|
| Texto | sí | parcial | sí |
| Autor | sí | sí | sí |
| Fecha | sí | sí | sí |
| Métricas | sí | no | visibles |
| Media | claves + URLs | descarga real | URLs |
| Enlaces | sí (entities) | no | sí |
| Contexto del hilo | con `conversation_id` | no | sí |
| **URL del post** | sí | sí | sí |

**Devuelve siempre la URL del post al chat**, venga por donde venga.

## Hilos

Con API, un hilo se reconstruye por `conversation_id`:
```bash
xurl "/2/tweets/search/recent?query=conversation_id:ID&tweet.fields=created_at,author_id,in_reply_to_user_id"
```
`search/recent` solo cubre los últimos 7 días en los planes básicos. Hilos antiguos requieren plan superior.

## Errores frecuentes

| Síntoma | Causa | Qué hacer |
|---|---|---|
| Open Graph vacío | X exige sesión | Vía 1 o 2 |
| `No video could be found` | El post no tiene vídeo | Correcto, no es fallo |
| 401 en xurl | Credenciales mal o caducadas | Reconfigurar `/xurl` |
| 429 | Rate limit de la API | Esperar; `websrc` respeta `Retry-After` |
| Selectores rotos en navegador | X cambió el DOM | Re-inspeccionar; es el coste de la vía 3 |

## Recomendación

Para lectura estable y en volumen: **API oficial**. Para media suelta de posts públicos: **yt-dlp**, que funciona hoy y sin credenciales. El navegador solo para casos puntuales que las otras dos no cubren, y sabiendo lo que implica.
