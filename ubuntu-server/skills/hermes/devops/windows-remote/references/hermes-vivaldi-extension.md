# Hermes Vivaldi Extension — Conexión en Windows

**Extensión:** Hermes para Vivaldi/Chrome
**ID Chrome Web Store:** `cnijbmieabkabeoaabiecokgjilejopo`
**ID real en Vivaldi (developer mode):** puede diferir del ID de la store.

---

## ⚠️ Distinción CRÍTICA: Gateway vs API Server

| Componente | Puerto | Para qué sirve | Quién conecta |
|---|---|---|---|
| **Messaging Gateway** | 3055 | Telegram, WhatsApp, Discord, Slack, etc. | Bots de mensajería |
| **API Server (OpenAI-compatible)** | **8642** | **Extensión Hermes en Vivaldi/Chrome**, Open WebUI, LobeChat, etc. | **Navegador del usuario** |

> **La extensión Hermes-Vivaldi se conecta al API Server (puerto 8642), NO al gateway (3055).** Este error causó horas de debugging en 2026-08-04.

---

## Instalación en Vivaldi (Windows)

Vivaldi acepta extensiones de Chrome Web Store nativamente:

1. Abrir `vivaldi://extensions/`
2. Activar **Modo desarrollador** (esquina sup. der.)
3. Opción A — Chrome Web Store:
   - Ir a la tienda: `https://chromewebstore.google.com/detail/cnijbmieabkabeoaabiecokgjilejopo`
   - Click "Añadir a Vivaldi" → confirmar
4. Opción B — Cargar descomprimida (si tienes el `.crx` o carpeta fuente):
   - "Cargar descomprimida" → seleccionar carpeta con `manifest.json`

---

## Conexión al API Server Hermes (puerto 8642)

### En el Linux server (este equipo)

**config.yaml (`~/.hermes/config.yaml`):**
```yaml
gateway:
  api_server:
    enabled: true
    host: "0.0.0.0"        # CRÍTICO: no 127.0.0.1
    port: 8642
    key: "YOUR_HERMES_API_KEY"
    max_concurrent_runs: 10
```

**Systemd service (`~/.config/systemd/user/hermes-gateway.service`):**
```ini
Environment="API_SERVER_HOST=0.0.0.0"
Environment="API_SERVER_PORT=8642"
Environment="API_SERVER_ENABLED=1"
```

> **Variables de entorno en systemd tienen precedencia sobre config.yaml** para el gateway runner. Poner ambas asegura el bind correcto aunque una se ignore.

**Verificar bind:**
```bash
ss -ltnp | grep 8642
# Debe mostrar: 0.0.0.0:8642  (NO 127.0.0.1:8642)
```

**Reiniciar tras cambios:**
```bash
systemctl --user daemon-reload && systemctl --user restart hermes-gateway
```

### En el Windows (Vivaldi)

1. Extensión instalada → click icono → **Settings / Configuración**
2. **Gateway URL:** `http://YOUR_TAILSCALE_IP:8642` (IP Tailscale del Linux server + puerto 8642)
3. **API Key / Token:** `YOUR_HERMES_API_KEY` (el `key` de config.yaml)
4. Guardar → la extensión debería mostrar **"Connected" / verde**

---

## Troubleshooting verificado (2026-08-04)

### Windows offline en Tailscale
```
tailscale status → YOUR_TAILSCALE_IP  YOUR_HOSTNAME  ...  offline, last seen 4d ago
```
**Causa:** Windows apagado o Tailscale no corriendo.
**Solución:** Encender Windows → verificar icono Tailscale "Connected" → reintentar.

### SSH no conecta para automatizar
El alias `windows-krai` en `~/.ssh/config` tiene `RemoteCommand powershell.exe -NoLogo` + `RequestTTY yes` que rompe comandos no interactivos.
**Para scripting:** usar forma explícita sin alias:
```bash
ssh -o BatchMode=yes -o ConnectTimeout=10 -i ~/.ssh/YOUR_WIN_SSH_KEY \
  krailynd@YOUR_TAILSCALE_IP 'powershell.exe -NoProfile -Command "..."'
```

### Puerto 8642 no accesible desde Windows (PROBLEMA PRINCIPAL 2026-08-04)
**Síntoma:** `Test-NetConnection YOUR_TAILSCALE_IP -Port 8642` → `TcpTestSucceeded: False`

**Causa raíz:** El gateway levanta el API server en `127.0.0.1:8642` por defecto — **no accesible desde Tailscale**.

**Fix definitivo (config.yaml + systemd):**
```yaml
# config.yaml
gateway:
  api_server:
    enabled: true
    host: "0.0.0.0"
    port: 8642
    key: "YOUR_HERMES_API_KEY"
    max_concurrent_runs: 10
```

```ini
# systemd service
Environment="API_SERVER_HOST=0.0.0.0"
Environment="API_SERVER_PORT=8642"
Environment="API_SERVER_ENABLED=1"
```

**Verificación tras fix (Linux):**
```bash
ss -ltnp | grep 8642
# 0.0.0.0:8642  ← debe salir esto
```

**Verificación desde Windows (PowerShell):**
```powershell
Test-NetConnection YOUR_TAILSCALE_IP -Port 8642
# TcpTestSucceeded: True

Invoke-RestMethod -Uri "http://YOUR_TAILSCALE_IP:8642/health" `
  -Headers @{"Authorization"="Bearer YOUR_HERMES_API_KEY"}
# status platform     version
# ------ --------     -------
# ok     hermes-agent 0.19.0
```

### Extensión no conecta (gateway OK)
- Verificar que la extensión tiene permisos de "Sitio" para la IP Tailscale
- Verificar `vivaldi://net-internals/#sockets` en Vivaldi para ver conexiones
- Logs de la extensión: `vivaldi://extensions/` → detalles → "Inspeccionar vistas: service worker" → Console

---

## ⚠️ Limitación de `browser-ctl` (skill `vivaldi`)

`browser-ctl` controla **Vivaldi en la MISMA máquina donde corre el bridge** (puerto 8770).

| Escenario | ¿Funciona? |
|---|---|
| Vivaldi en **este Linux server** | ✅ Sí |
| Vivaldi en **Windows del usuario** | ❌ No — bridge no ve ese navegador |
| Chrome en **Windows del usuario** | ❌ No |

**Conclusión:** No intentes automatizar el Vivaldi/Chrome de Windows desde este servidor Linux con `browser-ctl`. El usuario debe configurar la extensión manualmente (2 clicks). La automatización por SSH del storage de la extensión es frágil y no vale el esfuerzo.

---

## Automatización via SSH (cuando Windows online)

Si necesitas verificar estado de la extensión por SSH:

```powershell
# Verificar que la extensión está instalada y cargada
$extId = "cnijbmieabkabeoaabiecokgjilejopo"  # puede cambiar en modo developer
$vivaldiProfile = "$env:LOCALAPPDATA\Vivaldi\User Data\Default"
$prefPath = "$vivaldiProfile\Preferences"

# Leer preferencias (la extensión guarda config en localStorage/chrome.storage.sync)
# Parsear JSON es complicado por storage aislado — forma fiable: usuario lo hace manual
```

---

## Checklist de conexión completa

- [ ] Windows encendido, Tailscale "Connected"
- [ ] `tailscale status` muestra Windows online (`active; direct ...`)
- [ ] SSH a Windows responde (verificación rápida: hostname + user + fecha)
- [ ] Gateway Hermes corriendo en Linux (`systemctl --user status hermes-gateway`)
- [ ] **Puerto 8642 bind en 0.0.0.0** (`ss -ltnp | grep 8642` → `0.0.0.0:8642`)
- [ ] Puerto 8642 accesible desde Windows (`Test-NetConnection ... -Port 8642` → True)
- [ ] Health check responde (`Invoke-RestMethod .../health` → `ok hermes-agent`)
- [ ] Extensión instalada en Vivaldi (Chrome Web Store o descomprimida)
- [ ] Extensión configurada con `http://YOUR_TAILSCALE_IP:8642` + API Key
- [ ] Extensión muestra "Connected" / verde

---

## Proveedores de IA — problema aparte

Si el health check y `/v1/models` funcionan pero **chat/completions falla**:

| Proveedor | Síntoma | Qué revisar |
|---|---|---|
| `omniroute` (kimi-default @ 127.0.0.1:20128) | 401 Unauthorized | Token expirado / credenciales OMNIROUTE_API_KEY |
| `nvidia-nim` (fallback) | Timeout | API externa lenta / cuota agotada |

**Esto NO es problema de conectividad gateway-extensión.** Es problema de credenciales/proveedores en `config.yaml` → sección `providers:` y `fallback_providers:`.