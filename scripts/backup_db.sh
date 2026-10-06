#!/usr/bin/env bash
set -euo pipefail

DATABASE_URL="${DATABASE_URL:-}"
BACKUP_DIR="${BACKUP_DIR:-$HOME/elite-placo-backups}"

if [[ -z "$DATABASE_URL" ]]; then
  echo "DATABASE_URL doit contenir l'URL PostgreSQL. Ne la committez jamais." >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$(mkdir -p "$BACKUP_DIR" && cd "$BACKUP_DIR" && pwd)"
case "$BACKUP_DIR" in
  "$REPO_ROOT"|"$REPO_ROOT"/*)
    echo "BACKUP_DIR doit être hors du dépôt : $REPO_ROOT" >&2
    exit 1
    ;;
esac

command -v pg_dump >/dev/null 2>&1 || { echo "pg_dump est introuvable." >&2; exit 1; }
STAMP="$(date +%Y%m%d-%H%M%S)"
OUTPUT="$BACKUP_DIR/elite-placo-$STAMP.dump"
pg_dump "$DATABASE_URL" --format=custom --no-owner --no-privileges --file="$OUTPUT"
echo "Sauvegarde créée hors du dépôt : $OUTPUT"
