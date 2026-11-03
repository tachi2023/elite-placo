# Passation - Élite Placo & Déco

Document sans secret. Les mots de passe, clés privées et URLs contenant des
identifiants de connexion doivent rester dans un gestionnaire de mots de passe.

## État au 03/11/2026

- Branche de production : `main`.
- Dernier commit fonctionnel de référence : voir l’historique de `main`.
- Branche Flutter Web publiée par CI : `deploy-app`.
- Migrations Flyway V1 à V17 : ne jamais modifier ni supprimer.
- Version applicative : `0.1.0-mvp`.

## URLs de production

- API : `https://elite-placo-api-oregon-9q65.onrender.com`
- Site vitrine : `https://elite-placo-site-9q65.onrender.com/`
- App Flutter Web/PWA : `https://elite-placo-app-9q65.onrender.com/`
- Espace client : `https://elite-placo-site-9q65.onrender.com/espace-client`
- Santé API : `https://elite-placo-api-oregon-9q65.onrender.com/actuator/health`
- Workflow APK validé : `https://github.com/tachi2023/elite-placo/actions/runs/40816246121`

Les deux URLs statiques exactes doivent être ajoutées à `CORS_ORIGINS` dans le
service API. Les anciennes URLs Docker pourront être retirées uniquement après
validation et suppression des anciens services.

## Comptes et responsabilités

Compléter les propriétaires dans le gestionnaire de mots de passe :

| Service | Propriétaire | Emplacement du secret |
| --- | --- | --- |
| GitHub `tachi2023/elite-placo` | `<nom>` | Gestionnaire de mots de passe |
| Render | `<nom>` | Gestionnaire de mots de passe |
| PostgreSQL / Neon ou Render | `<nom>` | Gestionnaire de mots de passe |
| Cloudinary | `<nom>` | Gestionnaire de mots de passe |
| Apple / TestFlight, si utilisé | `<nom>` | Gestionnaire de mots de passe |

## Déploiement

1. Vérifier que Render suit `main` et que l’auto-deploy est actif.
2. Vérifier les logs Flyway V14 à V17 après chaque synchronisation Render.
3. Définir `ADMIN_PASSWORD`, les trois variables Cloudinary et les URLs CORS dans Render.
4. Le workflow **Build and publish Flutter Web** publie automatiquement `deploy-app`.
5. Vérifier `/actuator/health`, puis lancer `scripts/smoke.sh` avec
   `API_URL`, `ADMIN_USER`, `ADMIN_PASSWORD` et `FOLLOWUP_CODE`.
6. Passer `APP_DEMO_ENABLED=false` après saisie et validation des vrais chantiers.

## Sauvegardes

Les sauvegardes doivent être stockées hors du dépôt :

- Windows : `.\scripts\backup_db.ps1` avec `DATABASE_URL` et éventuellement `BACKUP_DIR`.
- Linux/macOS : `./scripts/backup_db.sh` avec `DATABASE_URL` et éventuellement `BACKUP_DIR`.

Faire une sauvegarde avant chaque migration et au moins une fois par semaine
pendant la période de recette. Tester périodiquement une restauration sur une
base séparée.

## Limites connues

- L'iPhone utilise la PWA en ligne ; le mode hors-ligne est réservé à Android.
- Le premier réveil d'une API Render gratuite peut être lent.
- Notifications push, messagerie et rendez-vous ne sont pas inclus dans cette
  version.
- Un APK de distribution doit être signé avec la clé privée sauvegardée hors Git.
- L’artefact APK GitHub est un APK de recette non signé par une clé Play Store ; il sert à installer et tester l’application sur Android.

## Coûts et renouvellements

Compléter après décision d'hébergement :

- Offre Render API : `<offre et coût>`.
- Base PostgreSQL : `<fournisseur, offre et coût>`.
- Cloudinary : `<offre et coût>`.
- Domaine : `<fournisseur, date de renouvellement et coût>`.

Ne jamais mettre de clé API, mot de passe, dump SQL ou fichier `key.properties`
dans GitHub.
