---
name: homeassistant
description: "Control Home Assistant (luces, switches, sensores, escenas, scripts) vía su REST API con el comando `hass`."
version: 1.0.0
author: sahacloud
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [Smart-Home, HomeAssistant, IoT, Automation, Lights, Sensors]
    homepage: https://homeassistant.sahacloud.dpdns.org
prerequisites:
  commands: [hass]
---

# Home Assistant

Controla el Home Assistant de SahaCloud desde la terminal vía su REST API.
El comando `hass` es un wrapper (`~/.local/share/hermes/tools/ha_control.sh`) que
lee las credenciales de `~/.hermes/.env` (`HA_URL`, `HA_LOCAL_URL`, `HA_API_TOKEN`).

- **URL pública**: https://homeassistant.sahacloud.dpdns.org
- **URL local** (por defecto, más rápida): http://localhost:8124
- Por defecto usa la URL local. Para forzar la remota: `HA_USE_REMOTE=1 hass <cmd>`.

## Prerequisitos

- El contenedor `sahacloud-homeassistant` debe estar corriendo (`docker ps | grep homeassistant`).
- `HA_API_TOKEN` en `~/.hermes/.env` debe ser un Long-Lived Access Token válido
  (Perfil de HA → *Tokens de acceso de larga duración* → Crear token).
- Verifica con: `hass ping`  (200 = OK; 401 = token inválido/placeholder).

## Cuándo usar

- "Enciende/apaga la luz/el switch de …"
- "¿Qué dispositivos hay?" / "estado del sensor …"
- "Alterna …", "pon la luz al 50%", "activa la escena/script …"
- Cualquier control o consulta de entidades de Home Assistant.

## Comandos

### Consultar

```bash
hass ping                 # Verifica API + token (muestra HTTP status)
hass states               # Todos los estados de entidades (JSON)
hass state light.sala     # Estado de una entidad concreta
hass services             # Servicios disponibles por dominio
hass config               # Config de la instancia de HA
```

Para listar solo las entidades de un dominio, filtra con jq/grep:

```bash
hass states | jq -r '.[].entity_id' | grep '^light\.'     # todas las luces
hass states | jq -r '.[].entity_id' | grep '^switch\.'    # todos los switches
```

### Controlar

```bash
hass turn_on  switch.tv          # Encender (dominio genérico homeassistant.turn_on)
hass turn_off switch.tv          # Apagar
hass toggle   light.cocina       # Alternar

# Llamar un servicio específico dominio.servicio sobre una entidad:
hass call light.turn_on   light.sala
hass call light.turn_off  light.sala
hass call scene.turn_on   scene.pelicula
hass call script.turn_on  script.buenas_noches
hass call cover.open_cover cover.garaje
```

## Dispositivos reales de esta casa (verificados en el registro)

- **`notify.sm_a146m`** → Samsung Galaxy A14 del usuario. Mandar notificación:
  `hass notify sm_a146m "tu mensaje"` (aparece como push en el teléfono).
- **`notify.z2450`** → teléfono ZTE. `hass notify z2450 "mensaje"`.
- `device_tracker.sm_a146m` / `device_tracker.z2450` → presencia (home/not_home/zona).
- `sensor.sm_a146m_battery_level`, `binary_sensor.sm_a146m_is_charging` → batería.
- `weather.forecast_casa` → clima (estado = condición; `temperature` es atributo).
- `sun.sun`, `sensor.sun_next_dawn/dusk` → sol (amanecer/atardecer).
- **TV Hyundai (Android TV)** → emparejada como **`media_player.tv`** y `remote.tv`.
  Usa el comando corto **`hass tv <sub>`**:
  - `hass tv off` / `hass tv on` — apagar / encender
  - `hass tv up` / `hass tv down` — subir / bajar volumen
  - `hass tv setvol 30` — volumen al 30%   ·   `hass tv mute` / `hass tv unmute`
  - `hass tv youtube` — abrir YouTube   ·   `hass tv youtube dQw4w9WgXcQ` — reproducir ese vídeo
  - `hass tv app https://www.netflix.com` — abrir cualquier app por su enlace
  - `hass tv home` / `hass tv back` / `hass tv play` / `hass tv key DPAD_UP` — mando
- **Scripts de HA** (también botones en la app): `script.tv_youtube`, `script.tv_netflix`,
  `script.tv_inicio`, `script.tv_apagar`, `script.tv_silenciar`, `script.buenas_noches`.
  Ejecutar: `hass call script.turn_on script.tv_youtube`.

Cuando el usuario diga "mándame X al teléfono" / "avísame en el celular", usa
`hass notify sm_a146m "X"`. Para "apaga/enciende la tv" usa
`hass call media_player.turn_off media_player.tv` (o turn_on).

## Convenciones de entity_id

Las entidades siguen `dominio.nombre` (todo en minúsculas, sin acentos):
`light.sala`, `switch.tv`, `sensor.temperatura_salon`, `scene.pelicula`,
`script.buenas_noches`, `cover.garaje`, `climate.termostato`, `media_player.tv`.

Usa siempre `hass states | jq -r '.[].entity_id'` para ver los IDs exactos
antes de actuar — son sensibles a mayúsculas/minúsculas y varían por instalación.

## Notas

- Red **bridge**: HA NO descubre dispositivos locales por mDNS/Bluetooth/USB en
  este montaje. Los dispositivos se añaden vía integraciones cloud o manualmente
  en la UI de HA. (Para hardware físico habría que pasar el contenedor a red host.)
- `hass` usa la URL local (`localhost:8124`) por defecto: no sale a internet y es
  más rápido. La ruta pública (túnel Cloudflare) es para acceso desde fuera.
- Para acciones con parámetros extra (brillo, color, temperatura), el cliente
  Python `~/.local/share/hermes/tools/homeassistant/ha_client.py` expone
  `set_light(entity_id, brightness=…, color=…)` y `call_service(...)` con datos.
