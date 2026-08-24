#!/usr/bin/env bash
# start-preview.sh — levanta preview temporal de un proyecto
# Uso: start-preview.sh <proyecto> [puerto] [--local-only]
# Ejemplo: start-preview.sh website              # puerto 4400, accesible en preview.sahacloud.dpdns.org
# Ejemplo: start-preview.sh website 4401 --local-only   # puerto alterno, solo accesible en localhost del servidor

set -euo pipefail

EXTERNAL_PORT=4400   # único puerto que Caddy/túnel enrutan a preview.sahacloud.dpdns.org

PROJECT="${1:?Uso: start-preview.sh <proyecto> [puerto] [--local-only]}"
PORT="${2:-${EXTERNAL_PORT}}"
LOCAL_ONLY_FLAG="${3:-}"

if [[ "${PORT}" != "${EXTERNAL_PORT}" && "${LOCAL_ONLY_FLAG}" != "--local-only" ]]; then
    echo "ERROR: Puerto ${PORT} no es el puerto externo (${EXTERNAL_PORT})."
    echo "Caddy y el túnel de Cloudflare solo enrutan preview.sahacloud.dpdns.org -> localhost:${EXTERNAL_PORT}."
    echo "Un preview en puerto ${PORT} NO será visible desde fuera del servidor."
    echo
    echo "Opciones:"
    echo "  1. Usa el puerto externo:      start-preview.sh ${PROJECT} ${EXTERNAL_PORT}"
    echo "  2. Confirma que es solo local: start-preview.sh ${PROJECT} ${PORT} --local-only"
    exit 1
fi

PREVIEW_DIR="/home/sahacloud/SahaCloud/previews"
BUILD_DIR="/home/sahacloud/SahaCloud/builds"
LOG_FILE="${PREVIEW_DIR}/${PROJECT}-${PORT}.log"
PID_FILE="/tmp/preview-${PORT}.pid"
PROJECT_DIR="/home/sahacloud/SahaCloud/proyectos/${PROJECT}"

# Validar que no hay otro proceso en ese puerto
if ss -tlnp | grep -q ":${PORT} "; then
    echo "ERROR: Puerto ${PORT} ya está en uso."
    ss -tlnp | grep ":${PORT} "
    exit 1
fi

# Validar que el proyecto existe
if [[ ! -d "${PROJECT_DIR}" ]]; then
    echo "ERROR: Proyecto '${PROJECT}' no encontrado en ${PROJECT_DIR}"
    exit 1
fi

mkdir -p "${PREVIEW_DIR}" "${BUILD_DIR}"

# Puerto externo (4400): debe bindear en 0.0.0.0 para ser alcanzable desde el
# contenedor de Caddy vía host.docker.internal (red bridge de Docker, no localhost).
# --local-only: se queda en 127.0.0.1 a propósito, para que sea de verdad solo local.
if [[ "${PORT}" == "${EXTERNAL_PORT}" ]]; then
    BIND_ADDR="0.0.0.0"
else
    BIND_ADDR="127.0.0.1"
fi

# Detectar tipo de proyecto y buildear
cd "${PROJECT_DIR}"

TIMESTAMP=$(date +%Y-%m-%d-%H%M)
BUILD_OUT="${BUILD_DIR}/${PROJECT}/${TIMESTAMP}"

echo "[$(date)] Iniciando preview de ${PROJECT} en puerto ${PORT}" | tee -a "${LOG_FILE}"

if [[ -f "package.json" ]]; then
    # Proyecto Node.js
    HAS_BUILD=$(jq -r '.scripts.build != null' package.json 2>/dev/null || echo "false")
    HAS_DEV=$(jq -r '.scripts.dev != null' package.json 2>/dev/null || echo "false")

    if [[ "${HAS_BUILD}" == "true" ]]; then
        echo "[$(date)] Build detectado, ejecutando npm run build..." | tee -a "${LOG_FILE}"
        npm run build >> "${LOG_FILE}" 2>&1

        # Intentar servir build estático con pm2 o python http.server
        if [[ -d "dist" ]]; then
            nohup python3 -m http.server "${PORT}" --directory dist --bind "${BIND_ADDR}" >> "${LOG_FILE}" 2>&1 &
        elif [[ -d ".next" ]]; then
            # Next.js: usar next start
            nohup npx next start -p "${PORT}" -H "${BIND_ADDR}" >> "${LOG_FILE}" 2>&1 &
        else
            echo "ERROR: No se encontró directorio de build (dist/ o .next/)" | tee -a "${LOG_FILE}"
            exit 1
        fi
    elif [[ "${HAS_DEV}" == "true" ]]; then
        echo "[$(date)] Levantando en modo dev en puerto ${PORT}..." | tee -a "${LOG_FILE}"
        nohup npm run dev -- -p "${PORT}" -H "${BIND_ADDR}" >> "${LOG_FILE}" 2>&1 &
    else
        echo "ERROR: Sin script build ni dev en package.json" | tee -a "${LOG_FILE}"
        exit 1
    fi
else
    # Servir directorio estático
    echo "[$(date)] Sirviendo como estático en puerto ${PORT}..." | tee -a "${LOG_FILE}"
    nohup python3 -m http.server "${PORT}" --directory . --bind "${BIND_ADDR}" >> "${LOG_FILE}" 2>&1 &
fi

PID=$!
echo "${PID}" > "${PID_FILE}"

# Esperar a que el puerto responda
echo "[$(date)] PID=${PID}, esperando que puerto ${PORT} responda..." | tee -a "${LOG_FILE}"
for i in $(seq 1 15); do
    if ss -tlnp | grep -q ":${PORT} "; then
        if [[ "${PORT}" == "${EXTERNAL_PORT}" ]]; then
            echo "[$(date)] Preview listo en https://preview.sahacloud.dpdns.org (puerto ${PORT})" | tee -a "${LOG_FILE}"
        else
            echo "[$(date)] Preview listo SOLO en http://127.0.0.1:${PORT} (--local-only, no expuesto por túnel)" | tee -a "${LOG_FILE}"
        fi
        exit 0
    fi
    sleep 1
done

echo "[$(date)] ERROR: Puerto ${PORT} no respondió tras 15s. Revisa ${LOG_FILE}" | tee -a "${LOG_FILE}"
exit 1
