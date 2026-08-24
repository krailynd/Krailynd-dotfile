---
name: navegador
description: "Operar el navegador Chrome principal del usuario en tiempo real mediante la extensión Hermes Browser Operator: abrir páginas, leer DOM, pulsar elementos, rellenar formularios, capturar pantallas y descargar archivos con sesiones iniciadas."
version: 3.0.0
author: sahacloud
license: MIT
platforms: [linux, windows]
metadata:
  hermes:
    tags: [browser, chrome, navegador, automation, web, operator, real-time]
    category: web
    related_skills: [computer-use, local-vision-draw, playwright]
---

# /navegador — Operador del Navegador Chrome en Tiempo Real

Esta skill reemplaza la antigua skill Vivaldi. Controlas el navegador **Google Chrome real** del usuario en su PC Windows mediante la extensión `Hermes Browser Operator` (`E:\entornos\hermes-chrome-extension`) y el puerto puente nativo `com.sahacloud.hermes_vivaldi`.

Usa las sesiones iniciadas del usuario (Google, NotebookLM, WhatsApp, Notion, GitHub, portales universitarios).

---

## 1. Verificación del Puente en Tiempo Real

```bash
browser-ctl status
```

Muestra las pestañas activas, estado de la conexión WebSocket/Native Host y ventana en foco.

---

## 2. Comandos de Control en Tiempo Real (`browser-ctl`)

### Navegación y Lectura
```bash
# Abrir página o cambiar de pestaña
browser-ctl open --url "https://notebooklm.google.com"

# Snapshot del DOM accesible (con IDs numéricos para clics)
browser-ctl snapshot

# Captura de pantalla en tiempo real (guardada en /tmp/screen.png)
browser-ctl screenshot --out /tmp/screen.png
```

### Interacción (Clics, Escritura y Desplazamiento)
```bash
# Pulsar elemento por ID de snapshot o selector CSS
browser-ctl click --ref @12
browser-ctl click --css "button.submit-btn"

# Escribir texto en campos de formulario
browser-ctl fill --ref @5 --text "mi_busqueda_o_credencial"

# Scroll vertical en tiempo real
browser-ctl scroll --direction down --amount 500
```

---

## 3. Fallback de Servidor (Headless Sandbox Ubuntu)

Si la PC Windows está apagada, Hermes utiliza el sandbox local de Chromium en Ubuntu:

```bash
start-hermes-browser.sh 98
```

---

## 4. Reglas de Uso en Tiempo Real

- Respetar sesiones iniciadas y credenciales del usuario.
- Limitar a un máximo de 3 pestañas activas para evitar consumo innecesario de RAM.
- Para evidencias o verificación visual, usar `browser-ctl screenshot` + `local-vision-ocr.py`.
