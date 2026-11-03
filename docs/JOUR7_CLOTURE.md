# Jour 7 - Clôture qualité et maintenance

## Objectif

Verrouiller la livraison après les jours 5 et 6 : chaque push sur `main` doit
tester l'API, le site vitrine et Flutter avant de produire les artefacts de
livraison.

## Contrôles automatisés

- API : `mvn -B -Plocal test`.
- Flutter : `flutter analyze`, `flutter test` et build Web release.
- Site vitrine : `npm ci` puis `npm run build`.
- APK : workflow `Build Android APK`, artefact `app-release.apk`.
- Smoke local : démarrage H2, connexion administrateur, suivi client autorisé,
  demande de devis publique, absence de données financières dans le suivi
  public et rejet d'un code client invalide.

## Résultat de la clôture du 03/11/2026

- Les validations locales sont passées.
- Le commit de clôture est publié sur `main`.
- La CI inclut désormais l'analyse et les tests Flutter, pas seulement le build.
- La documentation de passation contient les URLs de production et les règles
  de sauvegarde sans secret dans Git.

## Contrôles obligatoirement humains

- Vérifier dans Render que les trois services sont `Live` et que
  `ADMIN_PASSWORD`, `JWT_SECRET`, `CORS_ORIGINS` et les secrets Cloudinary sont
  définis dans les variables privées.
- Installer l'APK sur un téléphone Android réel et vérifier connexion, suivi,
  ajout de média et consultation hors ligne.
- Ouvrir la PWA sur iPhone et vérifier accueil, espace client et reconnexion.
- Conserver une sauvegarde PostgreSQL hors du dépôt et tester sa restauration
  sur une base séparée.

Ces quatre contrôles ne peuvent pas être déclarés réussis depuis la CI sans
accès au compte Render, aux secrets et aux appareils physiques.
