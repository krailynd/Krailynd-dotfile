#!/usr/bin/env bash
# stop-preview.sh — apaga preview temporal y limpia
# Uso: stop-preview.sh <puerto>
# Ejemplo: stop-preview.sh 4401

set -euo pipefail

PORT="${1:?Uso: stop-preview.sh <puerto>}"
PID_FILE="/tmp/preview-${PORT}.pid"

echo "[$(date)] Apagando preview en puerto ${PORT}..."

# Intentar matar por PID file
if [[ -f "${PID_FILE}" ]]; then
    PID=$(cat "${PID_FILE}")
    if kill -0 "${PID}" 2>/dev/null; then
        echo "[$(date)] Matando PID ${PID}..." 
        kill "${PID}" 2>/dev/null || true
        sleep 1
        kill -9 "${PID}" 2>/dev/null || true
    fi
    rm -f "${PID_FILE}"
fi

# Matar cualquier proceso restante en ese puerto
PID_ON_PORT=$(ss -tlnp | grep ":${PORT} " | grep -oP 'pid=\K[0-9]+' | head -1)
if [[ -n "${PID_ON_PORT}" ]]; then
    echo "[$(date)] Matando proceso residual PID ${PID_ON_PORT} en puerto ${PORT}..."
    kill "${PID_ON_PORT}" 2>/dev/null || true
    sleep 1
    kill -9 "${PID_ON_PORT}" 2>/dev/null || true
fi

# Verificar que el puerto quedó libre
if ss -tlnp | grep -q ":${PORT} "; then
    echo "[$(date)] ERROR: Puerto ${PORT} sigue ocupado después de intentar matar." 
    ss -tlnp | grep ":${PORT} "
    exit 1
fi

echo "[$(date)] Puerto ${PORT} liberado. Preview apagado."
