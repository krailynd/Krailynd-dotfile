---
name: agy-cli
description: Skill de Antigravity CLI (agy 1.1.10) para Hermes. Generación de imágenes, análisis visual y razonamiento con Gemini 3.1 Pro en Ubuntu o Windows.
---

# Antigravity CLI (agy) Skill para Hermes

Skill para invocar el motor **Antigravity CLI (agy)** respaldado por Gemini 3.1 Pro (Google AI Pro).

---

## 1. MÓDULOS DE EJECUCIÓN

### A. Generación de Imágenes Sin Restricciones
Invocación directa con limpiador automático de prompts:

```bash
python3 ~/.local/bin/local-image-gen.py --prompt "Descripción de la imagen..." --out /tmp/hermes_gen.png --model flux
```

### B. Invocación Antigravity CLI Directa
```bash
/home/sahacloud/.local/bin/agy -p "Prompt o tarea..." --dangerously-skip-permissions
```

### C. Conector Windows Remote (`ag-image-win.py`)
```bash
python3 ~/.local/bin/ag-image-win.py gen --prompt "..." --out /tmp/hermes_gen.png
```

---

## 2. REGLAS DE ENTREGA AL CHAT
1. Generar la imagen en `/tmp/hermes_gen.png`.
2. Enviar automáticamente al chat usando `hermes_send_file.sh /tmp/hermes_gen.png`.
3. Guardar copia opcional en Obsidian Vault `E:\YOUR_VAULT\Draw\`.
