---
name: java-windows-remote
description: "Compila/corre Java en el Windows de YOUR_NAME por SSH Tailscale."
version: 1.0.0
author: sahacloud
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [Java, Windows, SSH, Tailscale, PowerShell, javac, cross-host]
prerequisites:
  commands: [ssh, base64]
---

# java-windows-remote

YOUR_NAME tiene un Windows 11 (`YOUR_HOSTNAME`) reachable por Tailscale donde
compila y corre programas Java (JDK 25 LTS instalado, con `javac`). Este skill
cubre el flujo completo para montar un proyecto Java en esa máquina desde el
host Linux (SahaCloud, Ubuntu 26.04) sin tocar el Windows a mano.

No substituye a `/devforge` — es su complemento para la parte de ejecución
cross-host. `/devforge` decide la arquitectura y el código; este skill resuelve
cómo llega el código al Windows y cómo se compila y corre allí.

## Cuándo usar

- YOUR_NAME pide "crea un programa Java y córrelo en mi Windows".
- YOUR_NAME quiere probar algo en Java pero el target de ejecución es su Windows,
  no el Linux donde vive Hermes.
- Necesitas transferir código Java al Windows y ver la salida de su ejecución.

No usar si el target de ejecución es Linux (usa `/devforge` directo) o si es un
proyecto Spring Boot empaquetado — para eso vale el flujo normal, solo cambia el
destino del deploy.

## Conexión (ya configurada en `~/.ssh/config`)

```
Host windows-krai
    HostName YOUR_TAILSCALE_IP          # Tailscale; LAN fallback 192.168.0.4
    User krailynd
    IdentityFile ~/.ssh/YOUR_WIN_SSH_KEY
    RequestTTY yes
    RemoteCommand powershell.exe -NoLogo
    LocalForward 3055 127.0.0.1:3055
```

El Windows tiene OpenSSH for Windows (puerto 22) y **Java 25.0.2 LTS** con `javac`.
WinRM (5985/5986) y RDP (3389) están cerrados — toda la gestión va por SSH.

## Comandos no interactivos

El `RemoteCommand` del config fuerza PowerShell interactivo. En modo no
interactivo el stdin se cae a `cmd.exe` si no lo pides explícito:

```bash
ssh -i ~/.ssh/YOUR_WIN_SSH_KEY krailynd@YOUR_TAILSCALE_IP \
  'powershell.exe -NoProfile -Command "<comando>"'
```

Evita anillar comillas dobles dentro del `Command` — PowerShell las interpreta
mal. Para scripts largos escribe un `.ps1` y ejecútalo con `-File`, no `-Command`.

## Gotchas duros (verificados 2026-07-25)

Tres trampas que cuestan tiempo. El detalle completo y recetas paso a paso están
en `references/windows-ssh-java.md` — cargar ese archivo la primera vez.

1. **`scp` no funciona.** El subsistema SFTP del OpenSSH del Windows está
   deshabilitado (`subsystem request failed on channel 0`). Usar stdin pipe.
2. **`Set-Content -Encoding UTF8` mete BOM y rompe `javac`.** PowerShell 5 añade
   `\ufeff`; `javac` lo rechaza con `illegal character: '\ufeff'`. Solución
   byte-exacta: base64 en Linux + `[IO.File]::WriteAllBytes` en el Windows.
3. **Codepage.** Sin `chcp 65001`, emojis y box-drawing salen como `???`/`�`
   en la salida capturada por SSH. El programa corre bien — es solo la consola
   no interactiva. YOUR_NAME en su Windows Terminal real lo ve bien sin tocar nada.

## Trampa de Java al escribir apps de terminal interactivas

`System.in.available()` lanza `java.io.IOException` (compiler-checked). Si lo
usas para detectar input no bloqueante (cronómetros, temporizadores), wrapea:

```java
try {
    if (System.in.available() > 0) { /* ... */ }
} catch (java.io.IOException ignored) {}
```

Sin el try/catch el código NO compila. Fácil de olvidar porque `available()`
parece inofensivo. Los hilos que esperan input deben ser `daemon` para no
bloquear el cierre.

## Flujo completo

1. Verificar Java: `ssh ... 'java -version'`.
2. Crear carpeta proyecto: `'New-Item -ItemType Directory -Force -Path D:\ing-sistemas\<nombre>'`.
3. Compilar local en Linux primero (`javac`) — caza errores baratos antes de subir.
4. Subir el `.java` con base64 + `WriteAllBytes` (gotcha #2).
5. Compilar en Windows: `'Set-Location D:\ing-sistemas\<nombre>; javac <Clase>.java'`.
6. Probar no interactivo: `printf "0\n" | ssh ... 'java <Clase>'`.
7. Para salida en vivo (cronómetros etc.), `chcp 65001` (gotcha #3) y `timeout`.

## Estado y convención del workspace

`D:\ing-sistemas\` es la raíz acordada con YOUR_NAME. **Un proyecto = una carpeta**,
nada mezclado:

```
D:\ing-sistemas\
└── <nombre-proyecto>/
    ├── src/        (opcional)
    ├── tests/      (opcional)
    ├── docs/       (opcional)
    ├── <Clase>.java  (proyectos de un solo archivo, sin package)
    └── <Clase>.class
```

Para cosas de un solo archivo no hacen falta subcarpetas. Para proyectos serios
sí — una carpeta por proyecto, NUNCA mezclar código de dos proyectos en la misma.

## Límites con YOUR_NAME

- Antes de crear un proyecto nuevo, decir nombre + estructura. No asumir.
- Operaciones destructivas en el Windows (`Remove-Item -Recurse`, installs) →
  confirmar primero, igual que en Linux.

## Referencias

| Archivo | Contenido |
|---|---|
| `references/windows-ssh-java.md` | Recetas paso a paso: transferencia byte-exacta, manejo de BOM, codepage, ejemplo completo del reloj-terminal |
