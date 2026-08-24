---
name: firecrawl-search
description: "Búsqueda web y scraping estructurado con Firecrawl: convierte URLs a markdown limpio, rastrea sitios enteros y extrae datos con esquema. Requiere FIRECRAWL_API_KEY (servicio de pago con créditos). Usar cuando SearXNG local no basta: hace falta el CONTENIDO completo de las páginas, no solo los enlaces."
version: 1.0.0
author: sahacloud
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [Search, Scraping, Firecrawl, Markdown, Crawl]
prerequisites:
  commands: [curl, jq]
---

# Firecrawl

Endpoint verificado el 2026-07-22: `POST https://api.firecrawl.dev/v1/search` responde **403** sin clave — la ruta existe y exige autenticación.

**Antes de usar esto, prueba `/websearch-local`.** SearXNG es gratis y cubre la mayoría de búsquedas. Firecrawl gasta créditos; resérvalo para cuando necesites el contenido de la página convertido a markdown.

## Configuración

`~/.hermes/.env`:
```
FIRECRAWL_API_KEY=fc-...
```
Clave en https://firecrawl.dev (plan gratuito con créditos limitados).

## Scrape — una URL a markdown

Lo más útil del servicio: HTML sucio convertido a markdown legible.

```bash
source ~/.hermes/.env
curl -s -X POST "https://api.firecrawl.dev/v1/scrape" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"url":"https://example.com","formats":["markdown"]}' \
  | jq -r '.data.markdown'
```

## Search — buscar y traer contenido

```bash
curl -s -X POST "https://api.firecrawl.dev/v1/search" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query":"TERMINOS","limit":5}' \
  | jq -r '.data[] | "\(.title)\n  \(.url)\n"'
```

## Crawl — sitio entero (asíncrono)

Consume muchos créditos. Pon siempre `limit`.

```bash
JOB=$(curl -s -X POST "https://api.firecrawl.dev/v1/crawl" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"url":"https://example.com","limit":20}' | jq -r .id)

# el crawl es asíncrono: hay que consultar el resultado
curl -s "https://api.firecrawl.dev/v1/crawl/$JOB" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  | jq -r '.status, (.data[]?.metadata.sourceURL // empty)'
```

## Comprobar créditos antes de un trabajo grande

```bash
curl -s "https://api.firecrawl.dev/v1/team/credit-usage" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" | jq
```

## Reglas

- Sin `FIRECRAWL_API_KEY` no intentes nada: dirá 403. Comprueba la variable primero.
- Los parámetros exactos de `/v1/crawl` y `/v1/search` pueden cambiar entre versiones de la API. **Si un campo es rechazado, consulta https://docs.firecrawl.dev antes de adivinar otro nombre.**
- Nunca crawlees sin `limit`.
- Respeta `robots.txt` y los términos del sitio destino.
