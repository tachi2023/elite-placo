#!/usr/bin/env bash
set -euo pipefail

API_URL="${API_URL:-http://localhost:8081}"
ADMIN_USER="${ADMIN_USER:-raoul.michel}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-}"
FOLLOWUP_CODE="${FOLLOWUP_CODE:-DEMO-CLIENT}"

if [ -z "$ADMIN_PASSWORD" ]; then
  echo "ADMIN_PASSWORD doit être défini dans l'environnement du smoke test." >&2
  exit 1
fi

curl -fsS "$API_URL/actuator/health" >/dev/null
TOKEN=$(curl -fsS -X POST "$API_URL/api/auth/login" -H 'Content-Type: application/json' \
  -d "{\"identifiant\":\"$ADMIN_USER\",\"motDePasse\":\"$ADMIN_PASSWORD\"}" | \
  sed -n 's/.*"jetonAcces":"\([^"]*\)".*/\1/p')
test -n "$TOKEN"
AUTH="Authorization: Bearer $TOKEN"

curl -fsS "$API_URL/api/chantiers" -H "$AUTH" >/dev/null
curl -fsS "$API_URL/api/devis" -H "$AUTH" >/dev/null
QUOTE=$(curl -fsS -X POST "$API_URL/api/devis" -H 'Content-Type: application/json' \
  -d '{"nom":"Smoke Test","telephone":"+237600000000","email":"smoke@example.com","typeTravaux":"Platrerie"}')
printf '%s' "$QUOTE" | grep -q '"statut"' || { echo "La demande de devis publique n'a pas été acceptée." >&2; exit 1; }

FOLLOWUP=$(curl -fsS "$API_URL/api/suivi/$FOLLOWUP_CODE")
if printf '%s' "$FOLLOWUP" | grep -Eiq '"(depense|depenses|marge|resultatNet|totalDepenses)"'; then
  echo "Le suivi public expose une donnée financière interdite." >&2
  exit 1
fi
echo "Smoke test OK"
