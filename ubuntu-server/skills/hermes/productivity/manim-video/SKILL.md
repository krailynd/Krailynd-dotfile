---
name: manim-video
description: Generador y renderizador automático de vídeos de animación ManimCE (0.20.1). Ejecución nativa directa en Ubuntu Server y entrega del archivo MP4 en ACCESOS_RAPIDOS.
---

# Manim Video Generator Skill

Skill para crear, renderizar y entregar vídeos de animación ManimCE de alta calidad cinemática directamente al usuario.

---

## 1. EJECUCIÓN 100% NATIVA

- **Binario Activo**: `~/.local/bin/manim` (versión 0.20.1).
- **Proceso de Trabajo**:
  1. Escribir script Python en `/tmp/script.py`.
  2. Renderizar vídeo MP4: `manim -pqh /tmp/script.py Escena --media_dir /tmp/manim_media`.
  3. Copiar vídeo a `SahaCloud/ACCESOS_RAPIDOS/Escena.mp4`.
  4. Entregar vídeo al chat: `hermes_send_file.sh /home/sahacloud/SahaCloud/ACCESOS_RAPIDOS/Escena.mp4 video`.
