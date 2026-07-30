# Docker / Compose — Élite Placo & Déco

## Démarrage rapide

```bash
docker compose up -d --build
```

## Services disponibles

- Backend API: http://localhost:8080
- Site vitrine: http://localhost:3000
- Flutter Web: http://localhost:8081
- PostgreSQL: localhost:5432
- pgAdmin: http://localhost:5050

## Arrêt

```bash
docker compose down
```

## Données persistantes

Les volumes PostgreSQL et pgAdmin sont conservés entre les redémarrages.
