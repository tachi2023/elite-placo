#!/usr/bin/env bash
set -euo pipefail

API_URL="${API_URL:-http://localhost:8081}"
ADMIN_USER="${ADMIN_USER:-raoul.michel}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-changeme}"

curl -fsS "$API_URL/actuator/health" >/dev/null
TOKEN=$(curl -fsS -X POST "$API_URL/api/auth/login" -H 'Content-Type: application/json' \
  -d "{\"identifiant\":\"$ADMIN_USER\",\"motDePasse\":\"$ADMIN_PASSWORD\"}" | \
  sed -n 's/.*"accessToken":"\([^"]*\)".*/\1/p')
test -n "$TOKEN"
AUTH="Authorization: Bearer $TOKEN"

curl -fsS "$API_URL/api/chantiers" -H "$AUTH" >/dev/null
curl -fsS "$API_URL/api/devis" -H "$AUTH" >/dev/null
curl -fsS -X POST "$API_URL/api/devis" -H 'Content-Type: application/json' \
  -d '{"nom":"Smoke Test","telephone":"+237600000000","email":"smoke@example.com","typeTravaux":"Platrerie"}' >/dev/null
curl -fsS "$API_URL/api/suivi/DEMO-CLIENT" >/dev/null
echo "Smoke test OK"
