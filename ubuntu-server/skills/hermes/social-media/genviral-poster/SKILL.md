---
name: genviral-poster
description: "Publicar y programar contenido en Instagram, TikTok, Facebook, YouTube, Pinterest, X, Threads, Bluesky y LinkedIn mediante la API de Genviral. ESTADO: pendiente de configurar — la ruta de API no está verificada y falta GENVIRAL_API_KEY. Leer la documentación oficial antes de construir cualquier petición."
version: 0.1.0
author: sahacloud
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [SocialMedia, Publishing, Instagram, TikTok, Scheduling, Pendiente]
prerequisites:
  commands: [curl, jq]
---

# Genviral Poster — SIN VERIFICAR

## Estado real

Comprobado el 2026-07-22:
- `api.genviral.io` **resuelve por DNS**.
- `POST https://api.genviral.io/v1/posts` devuelve **404**.

404 sin autenticación indica que la ruta no existe (un endpoint real protegido daría 401/403). La ruta `/v1/posts` de las guías no es válida.

## Antes de usarlo

1. Clave en https://www.genviral.io/api-keys
2. Conectar las cuentas sociales en https://www.genviral.io/social — sin este paso, publicar falla aunque la clave sea correcta.
3. `GENVIRAL_API_KEY=...` en `~/.hermes/.env`
4. **Leer la documentación oficial** y anotar la ruta real, el campo de texto y el formato de plataformas y de `schedule_time`.
5. Actualizar este archivo con lo verificado y subir `version` a 1.0.0.

## Descubrir la ruta correcta

```bash
source ~/.hermes/.env
for p in /v1/post /v1/publish /v1/schedule /api/v1/posts; do
  printf "%-18s " "$p"
  curl -s -o /dev/null -w '%{http_code}\n' -X POST \
    -H "Authorization: Bearer $GENVIRAL_API_KEY" \
    -H "Content-Type: application/json" -d '{}' \
    --max-time 15 "https://api.genviral.io$p"
done
```
401/403 = ruta correcta, falta auth o cuerpo. 404 = ruta equivocada, sigue probando.

## Aviso de publicación

Publicar es **irreversible hacia fuera**: el contenido queda visible para terceros de inmediato. Confirma texto y plataformas con el usuario antes de cada envío. Para publicaciones programadas, confirma también la fecha y la zona horaria — un `schedule_time` mal interpretado publica a una hora que nadie esperaba.

## Alternativa

`/postproxy` — mismo propósito, mismo estado sin verificar.
