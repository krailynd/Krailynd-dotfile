---
name: tv-youtube-casting
description: "Buscar, filtrar por criterio (idioma, duración mínima, subtitulado) y reproducir un video de YouTube en la TV Hyundai de SahaCloud vía Home Assistant (`hass tv`). Usar cuando el usuario pida 'pon un video de YouTube sobre X en español de más de N minutos', 'reproduce en la tv', 'busca y pon un video del ceo de X', o cualquier solicitud de reproducir contenido de YouTube en la TV con criterios de búsqueda más allá de un ID conocido."
version: 1.0.0
author: sahacloud
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [Smart-Home, YouTube, TV, HomeAssistant, Media, Casting]
    homepage: https://homeassistant.sahacloud.dpdns.org
prerequisites:
  commands: [hass, yt-dlp]
  skills: [homeassistant]
---

# TV YouTube Casting — buscar, filtrar y reproducir en la TV Hyundai

Skill complementaria a `homeassistant`. Esa skill documenta el comando `hass tv`
(generic control). Esta skill documenta el **patrón de búsqueda + filtrado + casting**
cuando el usuario pide reproducir un video por criterio y no te da un ID directo.

## Cuándo usar

- "pon un video de YouTube sobre X en la TV"
- "busca un video del CEO de Anthropic/OpenAI/Nvidia de más de 10 minutos en español y ponlo en la tv"
- "reproduce en la tv una entrevista larga de X en español"
- Cualquier solicitud donde el video concreto no sea conocido y haya que elegirlo por tema + idioma + duración.

NO usar si el usuario ya da el video ID/URL — ejecuta directo `hass tv on` → `hass tv youtube <id>`.

## Prerequisitos

- `hass` operativo (`hass ping` → 200). El contenedor `sahacloud-homeassistant` corriendo.
- `yt-dlp` instalado (para `--flat-playlist` y para leer metadatos `duration`/`uploader`).
- `web_search` (SearXNG local) para discovery de candidatos.

## Flujo (paso a paso, verificado en sesión 2026-07-23)

### 1. Descubrir candidatos

Dos fuentes en paralelo (no bloqueantes):

```bash
# web_search — encuentra páginas indexadas con el tema + idioma
# (el resultado puede venir de YouTube, sitios de noticias, Instagram, etc.)
# Lanza una query tipo:
web_search "site:youtube.com <tema> <idioma>"

# yt-dlp flat search — flat playlist, rápido, no descarga nada
yt-dlp --flat-playlist -J "ytsearch10:<tema> <idioma>"
```

Batch de 5-10 resultados de cada. Los títulos y URLs de YouTube aparecen en `entries[].url`
y `entries[].id`.

### 2. Filtrar por duración (CRÍTICO)

El usuario casi siempre da un piso ("más de 10 minutos", "largo", "completo").
**No adivines la duración leyendo el título** — los nombres engañan. Pídelo a yt-dlp:

```python
import subprocess, json
candidates = [("o4xJcqldQMo", "Dentro de Anthropic"), ("jzpb2aLOz-Q", "Análisis..."), ...]
for vid, _ in candidates:
    r = subprocess.run(
        ["yt-dlp", "--no-playlist", "-J", "--skip-download", f"https://www.youtube.com/watch?v={vid}"],
        capture_output=True, text=True, timeout=60
    )
    if r.returncode == 0:
        d = json.loads(r.stdout)
        dur = d.get("duration", 0)        # segundos
        title = d.get("title","?"); upl = d.get("uploader","?")
        print(f"{vid} | {dur//60}m{dur%60}s | {upl} | {title}")
```

Descarta los que no pasen el umbral del usuario (≈ `dur >= 60 * min_minutes`).

### 3. Verificar idioma y "quien habla" (pitfall más común)

**El filtro por idioma en la búsqueda NO garantiza que el audio esté en ese idioma.**
Esto es especialmente decisivo en entrevistas a CEOs/fundadores (Dario Amodei, Jensen
Huang, Sam Altman, Elon, etc.) — las entrevistas reales con la persona son en inglés;
lo que existe en español suele ser:
- reportajes *sobre* la empresa/la persona con locutor en español (Bloomberg en Español, France24 Español),
- análisis/comentarios de terceros sobre la entrevista original,
- resúmenes cortos (<10 min) de creadores hispanos.

Verifica los campos `uploader` y el inicio del `description`:
- `FRANCE 24 Español`, `Bloomberg en Español`, `DW Español` → reportaje en español, no el CEO hablando.
- `xHubAI`, `Neura Media`, canales de analistas → formato "análisis de la entrevista", no la entrevista.
- `Dwarkesh Patel`, `Lex Fridman`, `Bloomberg Originals` → entrevista original en inglés.

Si el usuario pidió **al CEO hablando en español** y no existe, dilo honestamente
**antes de poner nada**: "no hay entrevistas largas de X hablando en español; lo que
hay en español son reportajes sobre él. Si te sirve una original en inglés con
subtítulos, te pongo esa." Deja la decisión al usuario. Poner un análisis de
terceros cuando esperaban la voz del CEO es una mala entrega silenciosa.

### 4. Ejecutar en la TV

```bash
hass ping                # confirma API 200
hass tv on               # enciende la TV (HTTP 200 si llegó el comando)
hass tv youtube <video_id>   # lanza YouTube y reproduce ese ID
```

Ambos devuelven `HTTP 200` si el comando llegó al Android TV. **No esperes a que
`hass state media_player.tv` diga `playing` antes de declarar hecho** — lee el pitfall.

### 5. Ajustar volumen

```bash
hass tv up              # sube 1 step -- repite 3-5 veces si hace falta
hass tv down           # baja 1 step
hass tv setvol 30       #absoluto (puede 500/400 en este setup -- ver skill homeassistant)
```

El comando `setvol` ha sido inestable en la TV Hyundai (HTTP 500/400 en sesiones
pasadas); `up`/`down` en bucle es el workaround seguro.

## Pitfall — `media_player.tv` queda `unavailable` tras `hass tv on`

**Síntoma:** justo después de `hass tv on` (y aún después de `hass tv youtube <id>`),
`hass state media_player.tv` reporta `state: unavailable` durante ~15-60 segundos.
La TV física está encendida y reproduciendo, los comandos devolvieron HTTP 200,
pero la integración de Android TV en HA no ha sincronizado todavía.

**No interpretar `unavailable` como "no llegó el comando"** mientras los comandos
devuelvan 200. No entres en un loop de reintentar `hass tv on` — eso apaga y
enciende la TV en cada retry. Tampoco dupliques `hass tv youtube <id>` — lanzar el
mismo ID dos veces seguidas reinicia la reproducción.

**Para confirmar reproducción sin leer `state`:**
- Sube el volumen con `hass tv up` 3-5 veces y verifica con el usuario ("¿ya se oye?").
- Si necesitas un feedback programático, `hass state media_player.tv` eventualmente
  pasa a `playing` / `paused` tras ~30-60 s — pero la mayoría de veces **no hace falta
  esperar**; el reporte al usuario de "ya está reproduciendo" se basa en los HTTP 200
  de los comandos, no en `state`.

## Entrega al usuario

Cuando termines, reporta:
- **Título, canal, duración** del video puesto (para que el usuario sepa qué eligió Hermes si hubo varios candidatos).
- Si elegiste un reportaje *sobre* el personaje en lugar de la entrevista con la persona
  misma, acláralo en UNA frase y ofrece la alternativa con subtítulos si existe.
- Nota sobre el estado final de la TV (encendida + reproduciendo + volumen ajustado).

## Notes

- La TV está en `media_player.tv` / `remote.tv` — ver `homeassistant` skill para el
  catálogo completo de sub-comandos (`hass tv off` para apagar al terminar, `hass tv play`/`pause` para control de reproducción, etc.).
- Si el primer candidato filtrado no reproduce bien, NO iteres lanzando IDs a ciegas —
  pregunta al usuario qué quiere hacer (siguiente candidato, subtítulos, apagar).
- Esta skill NO cubre búsqueda de contenido policy-violating; rechaza y explica si el
  tema del video cae fuera de lo permitido.
