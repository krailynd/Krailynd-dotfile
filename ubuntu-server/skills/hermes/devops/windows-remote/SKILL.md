---
name: windows-remote
description: "SSH al PC Windows de krailynd y gestion de proyectos ahi."
version: 1.0.0
author: sahacloud
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [windows, ssh, tailscale, powershell, remote, devops, krailynd, ing-sistemas]
    category: devops
    requires_toolsets: [terminal]
prerequisites:
  commands: [ssh]
---

# Windows Remote — SSH al PC Windows de krailynd

Operar el PC Windows del usuario (`YOUR_HOSTNAME`, Windows 11 Enterprise) desde Hermes en el Linux server, por SSH sobre Tailscale. Convierte `D:\ing-sistemas\` en la raíz donde cada proyecto vive en su propia carpeta, aislada.

## When to Use

- El usuario dice "en mi Windows", "mi PC", "el de escritorio", "D:\ing-sistemas", o nombra algo que está en su máquina Windows.
- Hay que crear, leer o ejecutar algo en `D:\ing-sistemas\<proyecto>\`.
- Se necesita diagnosticar algo en el Windows (procesos, disco, red) desde aquí.
- El usuario pide montar un proyecto nuevo y el destino implícito o explícito es su Windows.

No usar para: operaciones en el Linux server (usa las tools nativas), ni para Blackboard/UPSJB (usa las tools de n8n — ver HERMES.md).

## Conexión — datos verificados (2026-07-25)

| Dato | Valor |
|---|---|
| Host | `YOUR_HOSTNAME` |
| Usuario | `krailynd` |
| IP Tailscale | `YOUR_TAILSCALE_IP` |
| IP LAN | `YOUR_LAN_IP` |
| SO | Windows 11 Enterprise v10.0.26200 |
| Puerto SSH | 22 (OpenSSH for Windows) |
| Alias config | `windows-krai` (en `~/.ssh/config`) |
| Clave | `~/.ssh/YOUR_WIN_SSH_KEY` |

`~/.ssh/config` ya tiene:
```
Host windows-krai
    HostName YOUR_TAILSCALE_IP
    User krailynd
    IdentityFile ~/.ssh/YOUR_WIN_SSH_KEY
    RequestTTY yes
    RemoteCommand powershell.exe -NoLogo
    LocalForward 3055 127.0.0.1:3055
```

Sesión interactiva: `ssh windows-krai` → PowerShell directo. No usar para scripting (cae en cmd si no hay TTY correcto).

## Convención de proyectos — D:\ing-sistemas\

**Regla dura:** cada proyecto es UNA carpeta dentro de `D:\ing-sistemas\`. Nada mezclado. No pongas código de un proyecto dentro de otro.

```
D:\ing-sistemas\
├── <proyecto-1>\
│   ├── src\
│   ├── tests\
│   ├── docs\
│   ├── .git\
│   └── pom.xml | package.json | build.gradle
├── <proyecto-2>\
│   ├── src\
│   └── ...
```

- Estructura interna por proyecto: `src/` (código), `tests/`, `docs/`, archivo de build.
- Antes de crear un proyecto nuevo, DILE al usuario el nombre y la estructura. No asumas — confirma.
- Si la arquitectura pide otra convención (vertical slice por feature, hexagonal con `domain/` `application/` `infrastructure/`), la aplicas dentro de la carpeta del proyecto, no fuera.

Espacio en `D:` (al 2026-07-25): ~15 GB usados / ~43 GB libres.

## Patrón SSH — cómo ejecutar comandos

### Comando simple (una línea, sin comillas anidadas)

Funciona directo con comillas simples desde bash, PowerShell recibe el `-Command` literal:

```bash
ssh -o BatchMode=yes -o ConnectTimeout=10 -i ~/.ssh/YOUR_WIN_SSH_KEY krailynd@YOUR_TAILSCALE_IP \
  'powershell.exe -NoProfile -Command "Test-Path D:\ing-sistemas"'
```

### Múltiples comandos separados por `;`

```bash
ssh ... 'powershell.exe -NoProfile -Command "$env:COMPUTERNAME; $env:USERNAME; Get-Date -Format yyyy-MM-dd"'
```

### Script complejo (multi-línea, bucles, regex)

**NO intentes anidar backslashes a mano.** El triple bash→ssh→powershell destroza el escaping (`\\`, `\"`, `$` se reinterpretan en cada capa). Funciona para 1-2 líneas; falla con regex, comillas anidadas o arrays.

Patrón que SÍ funciona: escribe el script `.ps1` en Linux con `write_file`, inyéctalo por stdin:

```bash
# 1. write_file /tmp/probe.ps1 con el script completo (PowerShell nativo, sin escapar)
# 2. cat + ssh + powershell -Command -
cat /tmp/probe.ps1 | ssh -o BatchMode=yes -o ConnectTimeout=15 \
  -i ~/.ssh/YOUR_WIN_SSH_KEY krailynd@YOUR_TAILSCALE_IP "powershell.exe -NoProfile -Command -"
```

> **Pitfall:** `powershell -Command -` a veces solo ejecuta la PRIMERA línea y descarta el resto. Si tu script tiene más de una sentencia, envuélvelo en un bloque `& { ... }` o usa `Invoke-Expression (Get-Content -Raw /tmp/script.ps1)` como alternativa.

### Alias del config (sesión interactiva)

```bash
ssh windows-krai   # entra a PowerShell interactivo con TTY
```

No sirve para `execute_code` ni para comandos no interactivos — `RequestTTY yes` + `RemoteCommand` rompen el modo batch.

## Pitfalls verificados

### scp falla — subsistema SFTP desactivado

```bash
scp ... krailynd@HOST:/tmp/  →  "subsystem request failed on channel 0"
```

El OpenSSH for Windows de ese equipo NO tiene el subsistema SFTP habilitado. **No uses scp.** Alternativas:

- Para texto: `cat archivo | ssh ... "powershell.exe -NoProfile -Command Set-Content -Path ..."` (frágil por escaping).
- Para scripts: inyecta por stdin como arriba.
- Para binarios: no hay vía directa sin SFTP. Si hace falta, pedir al usuario que habilite el subsistema SFTP en su `sshd_config`.

### STTY/RemoteCommand rompe el modo batch

El `~/.ssh/config` tiene `RequestTTY yes` y `RemoteCommand powershell.exe -NoLogo` para sesión interactiva. Pero al ejecutar comandos no interactivos con `ssh windows-krai "comando"`, el RemoteCommand se antepone y se rompe. **Para scripting usa la forma explícita** (`ssh -i ~/.ssh/YOUR_WIN_SSH_KEY krailynd@YOUR_TAILSCALE_IP ...`), no el alias.

### Sin TTY cae en cmd.exe, no en PowerShell

Si ejecutas `ssh host "comando"` sin forzar PowerShell, OpenSSH for Windows ejecuta `cmd.exe` por defecto. `Select-Object`, `$_`, `Get-ChildItem` — todo falla con "no se reconoce como comando". **Siempre pasa `powershell.exe -NoProfile -Command "..."` explícito.**

### Rutas con backslash

PowerShell entiende `D:\ing-sistemas` con backslash simple. Dentro de un `-Command "..."` entre comillas dobles, backslash NO se escapa en PowerShell. Pero al pasar por bash→ssh, bash SÍ interpreta `\` en algunos contextos. Por eso para rutas usa comillas simples en la capa bash y dobles en la capa PowerShell:

```bash
# bien
ssh ... 'powershell.exe -NoProfile -Command "Get-ChildItem D:\ing-sistemas"'
# mal (bash traga el \in)
ssh ... "powershell.exe -NoProfile -Command \"Get-ChildItem D:\\ing-sistemas\""
```

### `Remove-Item -Recurse` es destructivo

Pide confirmación al usuario antes de borrar carpetas en su Windows. Es operación irreversible en su máquina real. La regla "nunca --force ni borrado destructivo sin confirmación explícita" aplica doble aquí — es su desktop, no un server desechable.

### API Server Hermes (puerto 8642) — acceso desde Vivaldi/Windows

Para que la extensión Hermes en Vivaldi (Windows) conecte al gateway, el API server debe escuchar en `0.0.0.0:8642` (no solo 127.0.0.1).

**Configuración en config.yaml (Linux server):**
```yaml
gateway:
  api_server:
    enabled: true
    host: "0.0.0.0"
    port: 8642
    key: "YOUR_HERMES_API_KEY"
    max_concurrent_runs: 10
```

**Variables de entorno en systemd service:**
```ini
Environment="API_SERVER_HOST=0.0.0.0"
Environment="API_SERVER_PORT=8642"
Environment="API_SERVER_ENABLED=1"
```

**Verificación desde Windows (PowerShell):**
```powershell
Test-NetConnection YOUR_TAILSCALE_IP -Port 8642
Invoke-RestMethod -Uri "http://YOUR_TAILSCALE_IP:8642/health" -Headers @{"Authorization"="Bearer YOUR_HERMES_API_KEY"}
```

**Pitfall:** Si el gateway solo escucha en 127.0.0.1, Windows no conecta aunque Tailscale esté up. Siempre verificar con `ss -ltnp | grep 8642` que muestra `0.0.0.0:8642`.

### `EncodedCommand` (base64) — usar con cuidado

PowerShell acepta `-EncodedCommand <base64>` que evita TODO el problema de escaping. Pero el base64 debe ser UTF-16LE, no UTF-8. `base64 -w0` en Linux produce UTF-8/base64 estándar y PowerShell puede mostrar warnings de codificación. Úsalo solo si el patrón stdin falla y el comando es largo.

## Operaciones comunes

| Tarea | Cómo |
|---|---|
| Existe una ruta | `'powershell.exe -NoProfile -Command "Test-Path D:\ruta"'` |
| Listar carpeta | `'powershell.exe -NoProfile -Command "Get-ChildItem D:\ruta -Force \| Format-Table Mode,LastWriteTime,Name -AutoSize"'` |
| Árbol recursivo | `'powershell.exe -NoProfile -Command "Get-ChildItem D:\ruta -Recurse \| ForEach-Object { $_.FullName }"'` |
| Crear carpeta | `'powershell.exe -NoProfile -Command "New-Item -ItemType Directory -Force -Path D:\ruta\sub"'` |
| Escribir archivo | `'powershell.exe -NoProfile -Command "Set-Content -Path D:\ruta\file.md -Value contenido -Encoding utf8"'` |
| Leer archivo | `'powershell.exe -NoProfile -Command "Get-Content D:\ruta\file.md"'` |
| Espacio en disco | `'powershell.exe -NoProfile -Command "$d=Get-PSDrive D; Write-Output ([math]::Round($d.Used/1GB,2)); Write-Output ([math]::Round($d.Free/1GB,2))"'` |
| Borrar carpeta | **CONFIRMAR PRIMERO** → `'powershell.exe -NoProfile -Command "Remove-Item -Path D:\ruta -Recurse -Force"'` |
| Hostname/user | `'powershell.exe -NoProfile -Command "$env:COMPUTERNAME; $env:USERNAME"'` |

## Verificación de conexión

Al inicio de una sesión que toca el Windows, verifica rápido:

```bash
WIN_IP=YOUR_TAILSCALE_IP
ssh -o BatchMode=yes -o ConnectTimeout=10 -i ~/.ssh/YOUR_WIN_SSH_KEY krailynd@$WIN_IP \
  'powershell.exe -NoProfile -Command "$env:COMPUTERNAME; $env:USERNAME; Get-Date -Format yyyy-MM-dd"'
```

Si devuelve 3 líneas (hostname, usuario, fecha), conexión OK. Si `Permission denied (publickey)`, la clave se rompió — avisar al usuario, no intentar password.

### Pre-check: Tailscale status (antes de SSH)

Si `tailscale status` muestra el Windows como `offline` (ej. `last seen 4d ago`), **no intentes SSH** — fallará con timeout. El Windows debe estar encendido y Tailscale corriendo (icono en bandeja → "Connected").

```bash
# Verificación rápida en una línea:
tailscale status | grep -E "100\.65\.159\.59|YOUR_HOSTNAME" || echo "Windows NO visible en Tailscale"
```

Si está offline: avisar al usuario que encienda su PC y verifique Tailscale. No reintentes a ciegas.

## Reglas firmes

- **NUNCA inventes** estado del Windows. Si un comando no corrió, no afirmes qué hay ahí.
- **Confirmación explícita antes de borrar** o modificar algo en su Windows. Es su máquina real.
- **Cada proyecto en su carpeta** dentro de `D:\ing-sistemas\`. Nunca mezcles.
- **No pidas credenciales** — la clave SSH ya está configurada. Si deja de funcionar, dilo y para. No intentes bypass.
- **No habilite WinRM/RSAT** por tu cuenta. Si hace falta gestión más profunda, pídelo. SSH+PowerShell basta para el 95%.
- Si el Windows está offline en Tailscale (`tailscale status` lo muestra offline), no reintentes a ciegas — avisa.

## Referencias

> **Reference:** Ver `references/ssh-powershell-escaping.md` para el detalle completo del triple bash→ssh→powershell: qué escape falla en cada capa, alternativas (stdin, EncodedCommand, here-strings) con ejemplos resueltos.
>
> **Reference:** Ver `references/hermes-vivaldi-extension.md` para la instalación y conexión de la extensión Hermes en Vivaldi (Windows), troubleshooting de Tailscale/gateway, y checklist de conexión completa.
