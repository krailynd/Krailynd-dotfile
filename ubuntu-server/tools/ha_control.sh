#!/usr/bin/env bash
# Control de Home Assistant para Hermes AI — SahaCloud.
# Lee credenciales de env o de ~/.hermes/.env (HA_URL / HA_LOCAL_URL / HA_API_TOKEN).
# Usa la URL local por defecto (más rápida, no pasa por el túnel). Para forzar la
# remota:  HA_USE_REMOTE=1 ha_control.sh states
#
# Uso: ha_control.sh <comando> [args]

set -euo pipefail

# Cargar SOLO las claves HA_ de ~/.hermes/.env (no se ejecuta el resto del
# archivo: un .env puede tener líneas que no son shell válido).
if [ -z "${HA_API_TOKEN:-}" ] && [ -f "$HOME/.hermes/.env" ]; then
  while IFS='=' read -r _k _v; do
    _v="${_v%\"}"; _v="${_v#\"}"; _v="${_v%\'}"; _v="${_v#\'}"
    case "$_k" in
      HA_URL)       HA_URL="${HA_URL:-$_v}" ;;
      HA_LOCAL_URL) HA_LOCAL_URL="${HA_LOCAL_URL:-$_v}" ;;
      HA_API_TOKEN) HA_API_TOKEN="${HA_API_TOKEN:-$_v}" ;;
    esac
  done < <(grep -E '^(HA_URL|HA_LOCAL_URL|HA_API_TOKEN)=' "$HOME/.hermes/.env" || true)
  export HA_URL HA_LOCAL_URL HA_API_TOKEN
fi

HA_LOCAL_URL="${HA_LOCAL_URL:-http://localhost:8124}"
HA_URL="${HA_URL:-https://homeassistant.sahacloud.dpdns.org}"
BASE="$HA_LOCAL_URL"
[ "${HA_USE_REMOTE:-0}" = "1" ] && BASE="$HA_URL"

if [ -z "${HA_API_TOKEN:-}" ]; then
  echo "Error: HA_API_TOKEN no está configurada (ni en env ni en ~/.hermes/.env)." >&2
  exit 1
fi

_auth=(-H "Authorization: Bearer $HA_API_TOKEN" -H "Content-Type: application/json")
_pp() { if command -v python3 >/dev/null; then python3 -m json.tool; else cat; fi; }

cmd="${1:-help}"
case "$cmd" in
  states)   curl -s "${_auth[@]}" "$BASE/api/states" | _pp ;;
  state)    [ -n "${2:-}" ] || { echo "Uso: $0 state <entity_id>"; exit 1; }
            curl -s "${_auth[@]}" "$BASE/api/states/$2" | _pp ;;
  services) curl -s "${_auth[@]}" "$BASE/api/services" | _pp ;;
  config)   curl -s "${_auth[@]}" "$BASE/api/config" | _pp ;;
  turn_on)  [ -n "${2:-}" ] || { echo "Uso: $0 turn_on <entity_id>"; exit 1; }
            curl -s "${_auth[@]}" -d "{\"entity_id\": \"$2\"}" \
                 "$BASE/api/services/homeassistant/turn_on"; echo "→ $2 encendido" ;;
  turn_off) [ -n "${2:-}" ] || { echo "Uso: $0 turn_off <entity_id>"; exit 1; }
            curl -s "${_auth[@]}" -d "{\"entity_id\": \"$2\"}" \
                 "$BASE/api/services/homeassistant/turn_off"; echo "→ $2 apagado" ;;
  toggle)   [ -n "${2:-}" ] || { echo "Uso: $0 toggle <entity_id>"; exit 1; }
            curl -s "${_auth[@]}" -d "{\"entity_id\": \"$2\"}" \
                 "$BASE/api/services/homeassistant/toggle"; echo "→ $2 alternado" ;;
  notify)   dev="${2:-}"; shift 2 2>/dev/null || true; msg="$*"
            [ -n "$dev" ] && [ -n "$msg" ] || { echo "Uso: $0 notify <sm_a146m|z2450> <mensaje>"; exit 1; }
            dev="${dev#notify.}"; dev="${dev#mobile_app_}"    # normaliza a slug del dispositivo
            payload=$(python3 -c 'import json,sys; print(json.dumps({"message": sys.argv[1], "title": "Hermes"}))' "$msg")
            curl -s "${_auth[@]}" -d "$payload" "$BASE/api/services/notify/mobile_app_$dev"
            echo "→ notificación enviada a $dev" ;;
  tv)       sub="${2:-}"; arg="${3:-}"
            mp="$BASE/api/services/media_player"; rm="$BASE/api/services/remote"
            _svc(){ curl -s -o /dev/null -w "  HTTP %{http_code}\n" "${_auth[@]}" -d "$2" "$1"; }
            case "$sub" in
              on)              _svc "$mp/turn_on"  '{"entity_id":"media_player.tv"}'; echo "TV encendida";;
              off)             _svc "$mp/turn_off" '{"entity_id":"media_player.tv"}'; echo "TV apagada";;
              up|vol+|subir)   _svc "$mp/volume_up"   '{"entity_id":"media_player.tv"}'; echo "volumen +";;
              down|vol-|bajar) _svc "$mp/volume_down" '{"entity_id":"media_player.tv"}'; echo "volumen -";;
              mute)            _svc "$mp/volume_mute" '{"entity_id":"media_player.tv","is_volume_muted":true}'; echo "silenciada";;
              unmute)          _svc "$mp/volume_mute" '{"entity_id":"media_player.tv","is_volume_muted":false}'; echo "sonido activado";;
              setvol)          v=$(python3 -c "print(max(0.0,min(1.0,int('${arg:-0}')/100)))"); _svc "$mp/volume_set" "{\"entity_id\":\"media_player.tv\",\"volume_level\":$v}"; echo "volumen $arg%";;
              play|pause)      _svc "$mp/media_play_pause" '{"entity_id":"media_player.tv"}'; echo "play/pause";;
              home)            _svc "$rm/send_command" '{"entity_id":"remote.tv","command":"HOME"}'; echo "HOME";;
              back)            _svc "$rm/send_command" '{"entity_id":"remote.tv","command":"BACK"}'; echo "BACK";;
              key)             _svc "$rm/send_command" "{\"entity_id\":\"remote.tv\",\"command\":\"$arg\"}"; echo "tecla $arg";;
              youtube)         case "$arg" in ""|https://*) link="${arg:-https://www.youtube.com}";; *) link="https://www.youtube.com/watch?v=$arg";; esac
                               _svc "$mp/play_media" "{\"entity_id\":\"media_player.tv\",\"media_content_type\":\"url\",\"media_content_id\":\"$link\"}"; echo "YouTube → $link";;
              app)             _svc "$mp/play_media" "{\"entity_id\":\"media_player.tv\",\"media_content_type\":\"url\",\"media_content_id\":\"$arg\"}"; echo "app → $arg";;
              *) echo "Uso: $0 tv {on|off|up|down|mute|unmute|setvol N|play|home|back|key TECLA|youtube [id]|app <link>}";;
            esac ;;
  call)     [ -n "${2:-}" ] && [ -n "${3:-}" ] || { echo "Uso: $0 call <domain.service> <entity_id>"; exit 1; }
            curl -s "${_auth[@]}" -d "{\"entity_id\": \"$3\"}" "$BASE/api/services/${2/./\/}" ;;
  ping)     curl -s -o /dev/null -w "HTTP %{http_code} ($BASE)\n" "${_auth[@]}" "$BASE/api/" ;;
  *)
    cat <<EOF
Home Assistant Control — Hermes AI (base: $BASE)
Uso: $0 <comando> [args]
  states                 Todos los estados de entidades
  state <entity_id>      Estado de una entidad
  services               Servicios disponibles
  config                 Config de HA
  turn_on <entity_id>    Encender
  turn_off <entity_id>   Apagar
  toggle <entity_id>     Alternar
  notify <disp> <msg>    Notificar a un teléfono (disp: sm_a146m=Samsung, z2450=ZTE)
  tv <sub> [arg]         Control TV: on|off|up|down|mute|setvol N|play|home|back|
                         key TECLA|youtube [id]|app <link>
  call <dom.svc> <eid>   Llamar servicio (p.ej. call light.turn_on light.sala)
  ping                   Verificar API + token
Env: HA_USE_REMOTE=1 fuerza la URL pública en vez de la local.
EOF
    ;;
esac
