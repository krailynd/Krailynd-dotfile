#!/usr/bin/env bash
# update.sh — pull latest images and restart stacks
# Run during a maintenance window
set -euo pipefail

INFRA=/home/sahacloud/sahacloud-infra
STACKS=("core" "nextcloud" "mattermost" "outline" "website")

echo "=== SahaCloud Update ==="

# Backup first
echo "[1/3] Running backup..."
bash "$INFRA/scripts/backup.sh"

# Pull new images
echo "[2/3] Pulling images..."
for stack in "${STACKS[@]}"; do
  echo "  → $stack"
  docker compose -f "$INFRA/stacks/$stack/docker-compose.yml" pull
done

# Restart with new images
echo "[3/3] Restarting stacks..."
for stack in "${STACKS[@]}"; do
  echo "  → $stack"
  docker compose -f "$INFRA/stacks/$stack/docker-compose.yml" up -d --remove-orphans
done

echo ""
echo "=== Update complete. Running health check... ==="
bash "$INFRA/scripts/health.sh"
