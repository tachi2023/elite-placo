# Jour 4 - Mise en ligne

## Ordre obligatoire

1. Sur Render, exporter la base PostgreSQL actuelle avant toute synchronisation du Blueprint.
2. Fusionner la PR `jour-3` vers `main` après le passage de la CI.
3. Dans le service API, définir les variables privées `ADMIN_PASSWORD`,
   `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY` et `CLOUDINARY_API_SECRET`.
4. Synchroniser le Blueprint. Les migrations V1 à V17 ne doivent jamais être
   modifiées ni supprimées.
5. Vérifier `https://<api>/actuator/health`, puis lancer `scripts/smoke.sh` avec
   `API_BASE_URL` configurée sur l'URL de production.
6. Quand les vrais chantiers sont saisis, passer `APP_DEMO_ENABLED` à `false`.

## Services statiques

Le Blueprint contient désormais `elite-placo-site-static`, qui construit
`apps/web` avec Vite et publie `dist`. Il contient aussi `elite-placo-app-static`.
Ce dernier publie la branche `deploy-app`, alimentée par
`.github/workflows/flutter-web-deploy.yml`.

Après la première création des services, recopier leurs URLs exactes dans
`CORS_ORIGINS` du service API Render. Une modification de CORS nécessite un
redéploiement de l'API.

## iPhone

Ouvrir l'URL de `elite-placo-app-static` dans Safari, puis **Partager** →
**Sur l'écran d'accueil** → **Ajouter**. L'application web reste connectée au
serveur : l'offline complet est réservé à l'APK Android dans cette version.

## APK Android

Créer une clé locale et ne jamais la commit :

```powershell
keytool -genkeypair -v -keystore apps/mobile/android/elite-placo-upload.jks `
  -keyalg RSA -keysize 2048 -validity 10000 -alias elite-placo
```

Créer ensuite `apps/mobile/android/key.properties` avec les chemins et mots de
passe de cette clé. Ce fichier et les fichiers `.jks` sont ignorés par Git.
Construire l'APK signé depuis `apps/mobile` :

```powershell
flutter pub get
flutter build apk --release --dart-define=API_BASE_URL=https://<api-production>
```

Le workflow GitHub produit un artefact de test, mais il ne doit pas servir à
distribuer une mise à jour Play Store tant qu'une clé privée n'est pas injectée
dans les secrets CI.
