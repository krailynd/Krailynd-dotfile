#!/usr/bin/env bash
# health.sh — SahaCloud full service health check
set -euo pipefail

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
OK="${GREEN}✓${NC}"; FAIL="${RED}✗${NC}"; WARN="${YELLOW}!${NC}"
PASS=0; FAIL_COUNT=0

check() {
  local name="$1"; local cmd="$2"
  if eval "$cmd" &>/dev/null; then
    echo -e "  ${OK} $name"
    PASS=$((PASS + 1))
  else
    echo -e "  ${FAIL} $name"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}

echo -e "\n${BLUE}══════════════════════════════════════════${NC}"
echo -e "${BLUE}       SahaCloud Health Check             ${NC}"
echo -e "${BLUE}══════════════════════════════════════════${NC}"
echo -e "  $(date '+%Y-%m-%d %H:%M:%S UTC')\n"

echo -e "${YELLOW}─── Infrastructure ───${NC}"
check "Caddy (reverse proxy)"   "docker exec sahacloud-caddy wget -qO- http://localhost:80/health"
check "Postgres"                "docker exec sahacloud-postgres pg_isready -U sahacloud_admin -d postgres"
check "Redis"                   "docker exec sahacloud-redis redis-cli ping"
check "Cloudflared (tunnel)"    "systemctl is-active --quiet cloudflared"
check "Docker daemon"           "systemctl is-active --quiet docker"
check "fail2ban"                "systemctl is-active --quiet fail2ban"

echo -e "\n${YELLOW}─── Applications ───${NC}"
check "Website (Next.js)"       "docker exec sahacloud-caddy nc -z -w5 sahacloud-website 3000"
check "Nextcloud"               "docker exec sahacloud-nextcloud curl -sf http://localhost:80/status.php"
check "Mattermost"              "docker exec sahacloud-caddy nc -z -w5 sahacloud-mattermost 8065"
check "Outline"                 "docker exec sahacloud-caddy nc -z -w5 sahacloud-outline 3000"
check "code-server"             "docker exec sahacloud-caddy nc -z -w3 sahacloud-code 8080"
check "AFFiNE"                  "docker exec sahacloud-caddy nc -z -w5 sahacloud-affine 3010"
check "Coolify"                 "docker exec sahacloud-caddy nc -z -w3 sahacloud-coolify 8080"
check "SahaTools"               "docker exec sahacloud-sahatools wget -qO- http://localhost:8080/health"

echo -e "\n${YELLOW}─── Hermes services ───${NC}"
check "Hermes gateway"          "systemctl --user is-active --quiet hermes-gateway"
check "Hermes dashboard"        "systemctl --user is-active --quiet hermes-dashboard"
check "Opencode web"            "systemctl --user is-active --quiet opencode-web"

echo -e "\n${YELLOW}─── Resources ───${NC}"
FREE_MB=$(free -m | awk 'NR==2 {print $7}')
DISK_PCT=$(df -h / | awk 'NR==2 {print $5}')
SWAP_MB=$(free -m | awk 'NR==3 {print $3}')
echo -e "  ${BLUE}→${NC} RAM available: ${FREE_MB}MB"
echo -e "  ${BLUE}→${NC} Disk used: ${DISK_PCT}"
echo -e "  ${BLUE}→${NC} Swap used: ${SWAP_MB}MB"
[ "$FREE_MB" -lt 300 ] && echo -e "  ${WARN} Low RAM! Consider running: sahaclean"

echo -e "\n${YELLOW}─── Summary ───${NC}"
TOTAL=$((PASS + FAIL_COUNT))
if [ "$FAIL_COUNT" -eq 0 ]; then
    echo -e "  ${OK} All ${TOTAL} checks passed"
else
    echo -e "  ${WARN} ${PASS}/${TOTAL} passed, ${FAIL_COUNT} failed"
fi
echo ""

echo -e "${YELLOW}─── Container status ───${NC}"
docker ps --format "  {{.Names}}: {{.Status}}" | grep sahacloud | sort
echo ""
