---
name: manim-scientific-animator
description: Skill de Animación Científica y Matemática 2D/3D con ManimCE 0.20.1. Arco narrativo pedagógico (3Blue1Brown), cero errores geométricos, renderizado nativo en Ubuntu Server y guardado directo en ACCESOS_RAPIDOS.
---

# Manim Scientific & Mathematical Animator Skill (manimCE v0.20.1)

Skill especialista para crear animaciones matemáticas, de IA, Deep Learning, física y algoritmos en Manim Community Edition sin excusas de entorno.

---

## 1. ESTADO DEL ENTORNO DE EJECUCIÓN (VERIFICADO & NATIVO)

- **Binario Manim**: `~/.local/bin/manim` (v0.20.1 en Ubuntu Server).
- **Ejecución Directa**: Cero requerimiento de SSH externo o terminal manual. Hermes ejecuta `manim` nativamente.
- **Ruta de Guardado Automático**:
  - `SahaCloud/ACCESOS_RAPIDOS/NombreEscena.mp4` (acceso instantáneo en Windows).
  - `SahaCloud/YOUR_VAULT/Media/NombreEscena.mp4` (Vault Obsidian).

---

## 2. ARCO NARRATIVO PEDAGÓGICO OBLIGATORIO (3BLUE1BROWN)

1. **HOOK (0–3s)**: Título en cyan (`#58C4DD`) con subtítulo descriptivo `self.add_subcaption()`.
2. **SETUP (3–6s)**: Aparición progresiva de elementos sobre rejilla sutil (`stroke_opacity=0.12`).
3. **DESARROLLO VISUAL (6–14s)**: Construcción de componentes. Prohibido usar `self.add()` estático. Uso obligatorio de `Create()`, `Write()`, `GrowFromCenter()`, `ValueTracker()` y `always_redraw()`.
4. **RIGOR GEOMÉTRICO ESTRICTO**:
   - Cateto horizontal $\Delta x = x_2 - x_1$ abajo.
   - Cateto vertical $\Delta y = y_2 - y_1$ a la derecha.
   - Hipotenusa $d = \sqrt{\Delta x^2 + \Delta y^2}$ en la diagonal.
5. **INSIGHT (14–17s)**: Destacar la fórmula clave con `SurroundingRectangle` e `Indicate`.
6. **CIERRE LIMPIO (17–20s)**: Limpieza con `self.play(FadeOut(Group(*self.mobjects)))`.

---

## 3. COMANDOS DE EJECUCIÓN INTERNA

```bash
# 1. Renderizar animación en Full HD 1080p
manim -pqh /tmp/script.py NombreEscena --media_dir /tmp/manim_media

# 2. Copiar a la carpeta compartida de Windows
cp /tmp/manim_media/videos/script/1080p60/NombreEscena.mp4 /home/sahacloud/SahaCloud/ACCESOS_RAPIDOS/

# 3. Notificar y entregar al chat
hermes_send_file.sh /home/sahacloud/SahaCloud/ACCESOS_RAPIDOS/NombreEscena.mp4 video
```
