# Élite Placo & Déco — Application de Gestion Comptable des Chantiers

Structure générée automatiquement (Phase 5 de la méthodologie du projet).
Aucune logique métier n'est encore implémentée : ce squelette pose
l'architecture (voir `Architecture_Technique_ElitePlaco.md`) et sera complété
en Phase 6.

## Prérequis

- Java 17+ et Maven (backend)
- Flutter SDK 3.3+ (frontend)
- PostgreSQL 14+ (base de données)

## Installation — Backend

```bash
cd backend
cp .env.example .env        # puis remplir les vraies valeurs
createdb eliteplaco          # créer la base PostgreSQL locale
psql eliteplaco < src/main/resources/db/migration/V1__init.sql
mvn spring-boot:run
```

L'API démarre sur `http://localhost:8080`.

## Installation — Frontend

```bash
cd frontend
flutter pub get
flutter run                  # mobile Android
flutter run -d chrome        # version web
```

## Structure du projet

```
elite-placo/
├── backend/                 # API Spring Boot
│   └── src/main/java/com/eliteplaco/api/
│       ├── entity/          # Entités JPA (Chantier, MouvementFinancier...)
│       ├── repository/      # Accès aux données (Spring Data)
│       ├── controller/      # Endpoints REST
│       ├── service/         # Logique métier (à implémenter en Phase 6)
│       ├── security/        # JWT (accès + rafraîchissement)
│       └── dto/             # Objets d'échange avec le client
├── frontend/                # Application Flutter
│   └── lib/
│       ├── models/          # Modèles de données
│       ├── providers/       # Gestion d'état (Provider)
│       ├── repositories/    # Choix local (SQLite) ou API selon connexion
│       ├── services/        # Appels API, PDF, partage
│       └── screens/         # Écrans (auth, chantiers, dashboard)
└── docs/                    # Cahier des charges, architecture, diagrammes
```

## Périmètre du MVP

Voir `Architecture_Technique_ElitePlaco.md` pour le détail complet des choix
d'architecture et leur justification. Résumé :

- ✅ Inclus : Modules 1, 2, 4 ; authentification JWT avec refresh token ;
  chiffrement de la base locale ; verrouillage PIN avec blocage progressif.
- ⏸️ Repoussé en roadmap : Modules 3/5/6/7 complets, synchronisation
  bidirectionnelle avec résolution de conflits, rate limiting API, audit
  trail détaillé, biométrie, multi-rôles.

## Prochaine étape (Phase 6)

Implémenter la logique métier : `ChantierService` (calcul résultat net /
marge / indicateur), `AuthController` + `JwtService` (login/refresh), et les
écrans Flutter correspondants.

### Lancer en développement sans PostgreSQL

Si vous n'avez pas PostgreSQL localement et que vous voulez démarrer rapidement
le backend avec une base en mémoire H2 (profil `local`) :

```bash
cd backend
mvn -Dspring-boot.run.profiles=local spring-boot:run
```

Ce profil utilise une base H2 en mémoire et désactive Flyway pour éviter
les migrations PostgreSQL en local.
