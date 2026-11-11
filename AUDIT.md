# Audit Sprint 0

## Conclusion

Le monorepo compile localement et les tests existants passent. L'API Spring
Boot obtient 24 tests Maven verts, Flutter obtient 4 tests verts et son analyse
ne signale aucune erreur. Le site React/Vite et Flutter Web produisent leurs
builds release.

Le projet n'est toutefois pas encore démontré comme prêt pour une recette
réelle : l'API Render n'a pas répondu au contrôle `curl` du 10/11/2026, les
tests métier critiques sont incomplets, le mode hors ligne Web est explicitement
non supporté et plusieurs règles du cahier des charges restent non testées.

## Périmètre et preuves

Sources disponibles :

- `docs/Cahier_des_Charges_ElitePlaco_v2.docx`.
- `CLAUDE.md` et la documentation du dépôt.
- Code, migrations, tests et workflows présents dans ce dépôt.

Les fichiers `elite.md`, `Architecture_Technique_ElitePlaco.md` et
`scenarios_ElitePlaco.html` cités par le prompt ne sont pas présents dans le
dépôt. La conformité exacte aux scénarios `SC-01.1` à `SC-08.3` et à tous les
paragraphes `§10.1` à `§10.16` devra être confirmée lorsqu'ils seront fournis.

## Cartographie

| Composant | Entrée | Technologie | État observé |
| --- | --- | --- | --- |
| API | `apps/api/src/main/java/.../ElitePlacoApiApplication.java` | Java 17 cible, Spring Boot 3.3, JPA, Flyway, JWT, PostgreSQL | Compile et tests verts |
| Mobile | `apps/mobile/lib/main.dart` | Flutter 3.38.7, Provider, Dio, SQLite SQLCipher natif | Analyse et tests verts |
| Site vitrine | `apps/web/src/main.tsx` | React 19, Vite 8, TypeScript 6, Tailwind | Build vert |
| Déploiement | `render.yaml`, `.github/workflows/` | Render, Docker, GitHub Actions | Configurée, recette distante à confirmer |
| Contrats | `packages/api-contracts/README.md` | Contrat documenté | Présent, pas de génération automatique observée |

Variables principales : PostgreSQL, `JWT_SECRET`, `ADMIN_PASSWORD`,
`CORS_ORIGINS`, `APP_DEMO_ENABLED`, `VITE_API_URL` et l'API Cloudinary.
`.env.example` est présent pour l'API. Il n'y a pas de secret détecté dans le
statut Git courant.

## Builds et tests exécutés

| Commande | Résultat | Preuve |
| --- | --- | --- |
| `mvn -B -Plocal verify` | ✅ 24 tests, 0 échec | Build Maven SUCCESS |
| `flutter analyze` | ✅ aucune erreur | `No issues found!` |
| `flutter test` | ✅ 4 tests, 0 échec | `All tests passed!` |
| `flutter build web --release` | ✅ build généré | `Built build/web` |
| `npm run build` | ✅ build généré | Vite terminé |
| `curl` API Render `/actuator/health` | ❌ timeout 30 s, 0 octet | HTTP non obtenu |
| `curl` site Render `/` | ✅ HTTP 200 | Réponse HTML reçue en 13,7 s |
| `curl` app Render `/` | ✅ HTTP 200 | Réponse HTML reçue en 13,3 s |

Le build React signale seulement un bundle JavaScript d'environ 501 kB après
minification. Flutter signale des dépendances pouvant être mises à jour ; ce
ne sont pas des erreurs de compilation.

## Matrice de conformité MVP

| Module | Statut | Constat vérifiable | Manque principal |
| --- | --- | --- | --- |
| 1. Chantiers | 🟡 Partiel testé | Création, liste, statuts, archivage et conflits sont codés ; plusieurs tests de service passent. | Pas de parcours HTTP complet testé et pas de matrice exhaustive des transitions UI. |
| 2. Finances | 🟡 Partiel | Encaissements, dépenses, modification, suppression et catégories existent. | La marge est calculée sur `totalEncaisse` dans `ChantierService.java:207-210`, alors que le cahier demande un pourcentage par rapport au devis signé. Tests absents pour les totaux, montants négatifs et cas limites réels. |
| 3. Matériaux | 🟡 Partiel | Deux systèmes, perte de 15 % et prix manquants sont pris en compte. | Catalogue configurable non identifié ; bande à joints et enduit ne passent pas par `Math.ceil` dans `MateriauxService.java:76-77`. Aucun test métier dédié. |
| 4. Dashboard | 🟡 Partiel testé | Endpoint et écrans existent. | Agrégations et graphique non couverts par un test automatisé ni une recette responsive documentée. |
| 5. Métrage | 🟡 Partiel | Surface nette, périmètre, déductions et limite de 30 pièces sont codés. | Déduction supérieure à la surface est silencieusement ramenée à zéro dans `MetrageService.java:91-95`, sans avertissement. Aucun test de 31e pièce, fiche vide ou PDF de bout en bout. |
| 6. Ouvriers | 🟡 Partiel | Paiement et remontée automatique en dépense main d'œuvre sont codés. | Le suivi de tâches simplifié du cahier n'est pas clairement matérialisé comme module persistant et n'est pas testé. |
| 7. Site vitrine | 🟡 Partiel testé | Pages React, formulaire de devis/contact, responsive CSS, contenu administrable et PWA existent. | Aucun test navigateur automatisé ni audit Lighthouse/accessibilité exécuté. |
| 7. Espace client | 🟡 Partiel testé | Lien unique, expiration, étapes, photos, documents et absence de champs financiers dans le DTO public sont testés en partie. | Le cahier demande aussi devis/encaissé/reste à payer ; le prompt impose au contraire zéro montant public. Décision métier nécessaire. Notifications SMS/WhatsApp non implémentées. |
| Hors ligne Android | 🟡 Partiel | SQLite SQLCipher, file d'attente, lots de 25 et identifiant d'opération existent. | Aucun test appareil/intégration perte réseau, retry, suppression, gros volume ou doublon. |
| Hors ligne Web/iPhone | ❌ Absent | Le facade Web lève volontairement `UnsupportedError` dans `local_db_service_web.dart:10-44`. | Prévoir IndexedDB ou limiter officiellement la PWA au mode en ligne. |
| Synchronisation | 🟡 Partiel | Push idempotent et delta présents. | Fusion locale basée sur `synchronise` sans comparaison `updatedAt` côté Flutter (`sync_service.dart:127-150`) ; déterminisme multi-appareils et horloges décalées non démontrés. |
| Sécurité | 🟡 Partiel testé | BCrypt, JWT, limitation des tentatives, CORS et séparation du DTO public existent. | Le refresh renvoie le même refresh token (`AuthService.java:68-78`) : rotation et détection de réutilisation absentes. Tests JWT expiré, CORS interdit, XSS/injection et endpoints HTTP protégés incomplets. |
| Sauvegardes | 🟡 Procédure présente | Scripts PowerShell et shell présents. | Aucune sauvegarde ou restauration réelle ne peut être prouvée sans accès à la base Render. |

## Tests manquants prioritaires

Les 24 tests Maven couvrent surtout le suivi client, la sécurité auxiliaire,
les statuts, la validation de devis, l'audit et un cas de synchronisation. Les
modules Finance, Matériaux, Métrage et Ouvriers ne disposent pas encore d'une
couverture métier équivalente. Le Web n'a pas de test automatisé et Flutter ne
possède que 4 tests ciblés sur l'authentification PIN et l'onboarding.

## Backlog priorisé

### Must Have

1. Corriger la formule de marge selon la règle métier confirmée, puis ajouter
   les tests des seuils 20 %, 5 %, devis nul, perte et dépenses supérieures aux
   recettes.
2. Ajouter les tests unitaires Finance, Matériaux, Métrage et Ouvriers demandés
   par le prompt, dont 31e pièce, déduction excessive et +15 % arrondi.
3. Décider et documenter la règle publique du suivi client : transparence
   financière ou masquage total.
4. Stabiliser la synchronisation Android avec tests d'idempotence, coupure,
   reprise, suppression et conflits `updatedAt`.
5. Vérifier l'API Render : health check, variables, migrations et smoke test
   authentifié avec un secret fourni hors dépôt.

### Should Have

1. Implémenter la rotation et la révocation des refresh tokens.
2. Ajouter tests HTTP d'authentification, JWT expiré, CORS interdit et
   validation d'entrées.
3. Ajouter une vraie persistance des tâches ouvriers si le module reste dans le
   MVP.
4. Ajouter tests navigateur du site et audit responsive/accessibilité.

### Could Have

1. Réduire le bundle React par séparation de code.
2. Ajouter une implémentation IndexedDB pour le hors-ligne PWA/iPhone.
3. Ajouter une signature Android de production et une procédure Play Store.

### Won't Have for the current MVP

Notifications SMS/push, messagerie et rendez-vous, rôles internes multiples,
planning avancé, fournisseurs et statistiques avancées restent dans la
roadmap, conformément au cahier des charges.

## Proposition du prochain sprint

Sprint 1 limité à cinq corrections maximum : tests Finance, correction et
validation de la formule de marge, tests Matériaux, tests Métrage, tests
Ouvriers. Aucune modification de design ni nouvelle fonctionnalité pendant ce
lot.

## Résultat du Sprint 1

Le Sprint 1 a été exécuté sur la branche `sprint-1-core-business` sans modifier
`main`. La validation complète `mvn -B -Plocal verify` est verte : 35 tests,
0 échec, 0 erreur.

| Commit | Correction | Preuve |
| --- | --- | --- |
| `d8159f3` | Marge calculée par rapport au devis signé, avec cas devis nul et perte | 12 tests `ChantierServiceTest` |
| `092e3c6` | Arrondi supérieur de toutes les quantités matériaux et budget incomplet | 2 tests `MateriauxServiceTest` |
| `25efe42` | Déduction négative refusée et avertissement si déduction supérieure à la surface | 3 tests `MetrageServiceTest` |
| `5976adf` | Paiement ouvrier relié à la dépense automatique Main d'œuvre et dates contrôlées | 3 tests `OuvrierServiceTest` |
| `560193a` | Date de dépense absente/future refusée et validation financière étendue | 2 tests `FinanceServiceTest` |

Le prochain lot ne doit pas commencer avant validation du dirigeant. Les
priorités restantes sont l'authentification complète et la rotation des
refresh tokens, puis la synchronisation hors ligne réelle sur appareil.
