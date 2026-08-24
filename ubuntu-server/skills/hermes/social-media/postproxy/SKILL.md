---
name: postproxy
description: "Publicar en varias redes sociales a la vez (Facebook, Instagram, TikTok, LinkedIn, YouTube, X, Threads, Pinterest, Bluesky, Telegram) mediante la API de Postproxy. ESTADO: pendiente de configurar — la ruta de API no está verificada y falta POSTPROXY_API_KEY. Leer la documentación oficial antes de construir cualquier petición."
version: 0.1.0
author: sahacloud
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [SocialMedia, Publishing, Instagram, Facebook, TikTok, LinkedIn, Pendiente]
prerequisites:
  commands: [curl, jq]
---

# Postproxy — SIN VERIFICAR

## Estado real

Comprobado el 2026-07-22:
- `api.postproxy.dev` **resuelve por DNS**.
- `POST https://api.postproxy.dev/v1/posts` devuelve **404**.

Un endpoint real protegido devolvería 401 o 403. El 404 significa que **esa ruta no existe**. La ruta `/v1/posts` que circula en guías es incorrecta o está obsoleta.

## Por tanto: no inventes la petición

**No construyas un `curl` a esta API adivinando la ruta.** Fallará y consumirá tiempo. Antes de la primera llamada:

1. Consigue la clave en https://app.postproxy.dev/api_keys
2. Ponla en `~/.hermes/.env` como `POSTPROXY_API_KEY=...`
3. **Lee la documentación oficial** y anota la ruta real de publicación, el nombre del campo de texto y el formato de la lista de plataformas.
4. Actualiza este archivo con los comandos verificados y sube `version` a 1.0.0.
5. Prueba primero con una sola plataforma antes de publicar en todas.

## Descubrir la ruta correcta

```bash
source ~/.hermes/.env
# ¿la raíz de la API responde y qué anuncia?
curl -s -i -H "Authorization: Bearer $POSTPROXY_API_KEY" \
  --max-time 15 "https://api.postproxy.dev/" | head -20

# probar rutas candidatas: 401/403 = existe pero requiere auth; 404 = no existe
for p in /v1/post /v1/publish /api/v1/posts /posts; do
  printf "%-18s " "$p"
  curl -s -o /dev/null -w '%{http_code}\n' -X POST \
    -H "Authorization: Bearer $POSTPROXY_API_KEY" \
    -H "Content-Type: application/json" -d '{}' \
    --max-time 15 "https://api.postproxy.dev$p"
done
```

## Aviso de publicación

Publicar en redes sociales es una **acción externa e irreversible**: queda visible para terceros al instante y borrarlo después no deshace lo visto. Confirma siempre con el usuario el texto exacto y las plataformas destino antes de enviar. Nunca publiques como parte de una tarea automática sin autorización explícita para esa publicación concreta.

## Alternativa

`/genviral-poster` cubre plataformas parecidas y está en el mismo estado (sin verificar). Ninguna de las dos está operativa todavía.
