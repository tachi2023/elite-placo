# Elite Placo & Déco

Monorepo de gestion des chantiers pour PRIMA BTP / Élite Placo & Déco.

Le dépôt regroupe trois applications complémentaires :

- un site vitrine React/Vite optimisé pour le référencement et l'espace client ;
- une application Flutter Android et Web pour le dirigeant ;
- une API Spring Boot avec PostgreSQL, JWT et synchronisation hors ligne.

## Structure

```text
elite-placo/
├── apps/
│   ├── api/                 # API Spring Boot, sécurité, services métier, migrations
│   ├── mobile/              # Flutter Android + Flutter Web, cache SQLite chiffré
│   └── web/                 # Site vitrine React/Vite et portail client
├── packages/
│   └── api-contracts/       # Contrats et conventions partagés entre les clients
├── docs/                    # Cahier des charges, scénarios et documentation projet
├── scripts/                 # Scripts reproductibles de build et de vérification
├── .github/workflows/       # CI Android et déploiement Render
├── docker-compose.yml       # Environnement local API + PostgreSQL + clients
└── render.yaml              # Blueprint Render API + site + Flutter Web
```

## Démarrage local rapide

### API avec H2 de démonstration

```powershell
cd apps/api
mvn -Plocal spring-boot:run
```

L'API locale écoute sur `http://localhost:8081` avec le profil `local`.

### Site vitrine

```powershell
cd apps/web
npm ci
npm run dev -- --host 0.0.0.0 --port 3000
```

Site : `http://localhost:3000`.

### Application Flutter Web

```powershell
cd apps/mobile
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8081
```

Version Web compilée :

```powershell
flutter build web --release --dart-define=API_BASE_URL=http://localhost:8081
```

### APK Android

```powershell
.\scripts\build_apk.ps1
```

L'APK est produite dans `apps/mobile/build/app/outputs/flutter-apk/`.

## Docker local

Depuis la racine :

```powershell
docker compose up --build
```

Services :

- API : `http://localhost:8081`
- site vitrine : `http://localhost:3000`
- Flutter Web : `http://localhost:5000`
- PostgreSQL : `localhost:5432`
- pgAdmin : `http://localhost:5050`

## Fonctionnalités couvertes

- gestion des chantiers et statuts ;
- suivi des encaissements, dépenses et marges ;
- calcul des matériaux ;
- fiches de métrage ;
- suivi des ouvriers ;
- tableau de bord global ;
- export PDF et partage ;
- authentification JWT, refresh token et verrouillage PIN ;
- fonctionnement hors ligne avec file d'actions, reprise et synchronisation delta ;
- idempotence des opérations de synchronisation ;
- portail client public sans exposition des données financières ;
- site vitrine avec identité visuelle Élite Placo & Déco.

## Vérifications

API :

```powershell
cd apps/api
mvn -Plocal test
```

Site :

```powershell
cd apps/web
npm ci
npm run build
```

Flutter :

```powershell
cd apps/mobile
flutter pub get
flutter build web --release --dart-define=API_BASE_URL=http://localhost:8081
```

## Déploiement

Le fichier `render.yaml` décrit trois services Render :

- `elite-placo-api` : API Spring Boot ;
- `elite-placo-site` : site vitrine React ;
- `elite-placo-app` : Flutter Web.

L'APK Android est construite par GitHub Actions et publiée comme artefact de workflow. Une
application mobile native ne se déploie pas comme une page Render : elle doit être installée via
l'APK de test ou publiée sur Google Play.

Consulter [README_DEPLOY.md](README_DEPLOY.md) pour la procédure Render et les variables d'environnement.
