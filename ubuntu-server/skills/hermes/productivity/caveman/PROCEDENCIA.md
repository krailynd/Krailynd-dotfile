# Procedencia

Origen: https://github.com/JuliusBrussee/caveman (MIT)
Copiado de `~/.claude/skills/caveman/` el 2026-07-21 durante la auditoria.

**Instalado a mano, NO con el instalador oficial.** El instalador es
`curl -fsSL .../install.sh | bash`, que delega en `npx -y github:$REPO`:
descarga y ejecuta codigo remoto sin revisar. Copiar los dos markdown evita
por completo esa via.

Solo se instalo el skill `caveman`. NO se instalaron:
  caveman-stats  — lee el log de sesion de Claude Code; fallaria en Hermes
  cavecrew       — depende de subagentes de Claude Code
  caveman-commit — flujo especifico de Claude Code
  caveman-compress — 7 scripts Python sin revisar; su ahorro sobre el bloque
                     de memoria de Hermes (2.064 B) seria de ~1 KB, no compensa

Desinstalar: borrar este directorio y reiniciar el gateway.
