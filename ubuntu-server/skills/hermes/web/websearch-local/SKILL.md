---
name: websearch-local
description: "Búsqueda web sin API key ni coste, contra la instancia SearXNG self-hosted de SahaCloud. Devuelve JSON con título, URL y snippet. Útil para buscar en la web, en un sitio concreto (site:), o para leer Reddit/foros que bloquean el acceso anónimo directo. Es la primera opción de búsqueda: gratis, privada y sin límite de créditos."
version: 1.0.0
author: sahacloud
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [Search, Web, SearXNG, SelfHosted, NoApiKey, Reddit]
prerequisites:
  commands: [curl, jq]
---

# Websearch local (SearXNG)

Instancia propia en `http://127.0.0.1:8181`. Sin API key, sin créditos, sin rate limit externo. **Probado el 2026-07-22: `format=json` devuelve 200.**

## Buscar

```bash
curl -s --max-time 20 \
  "http://127.0.0.1:8181/search?q=TERMINOS&format=json" \
  | jq -r '.results[:10][] | "\(.title)\n  \(.url)\n  \(.content // "" | .[0:160])\n"'
```

URL-encodea los espacios como `+`. Para frases exactas usa `%22...%22`.

## Restringir a un sitio

```bash
curl -s "http://127.0.0.1:8181/search?q=spring+boot+site:reddit.com&format=json" \
  | jq -r '.results[:10][] | {title, url}'
```

Así se lee Reddit, Stack Overflow o cualquier foro que bloquee el scraping directo: SearXNG consulta a los buscadores, no al sitio.

## Filtrar por motor o categoría

```bash
# solo un motor
curl -s "http://127.0.0.1:8181/search?q=TERMINOS&engines=duckduckgo&format=json"

# categorías: general, images, videos, news, it, science
curl -s "http://127.0.0.1:8181/search?q=TERMINOS&categories=news&format=json"
```

## Extraer solo URLs para pasarlas a otra herramienta

```bash
curl -s "http://127.0.0.1:8181/search?q=TERMINOS&format=json" \
  | jq -r '.results[:5][].url'
```

## Notas

- El servicio corre en el contenedor `sahacloud-searxng` (puerto `127.0.0.1:8181`). Si devuelve error de conexión:
  ```bash
  docker ps --filter name=sahacloud-searxng
  docker restart sahacloud-searxng
  ```
- No expone búsqueda hacia fuera; solo desde el propio servidor.
- Si un resultado necesita el contenido completo de la página, combínalo con `/browser-use` o con Firecrawl.
- Empieza siempre por aquí antes de gastar créditos de una API de pago.
