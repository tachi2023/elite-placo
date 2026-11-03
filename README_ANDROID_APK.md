# Génération de l'APK Android (local / CI)

Ce document décrit deux méthodes pour obtenir l'APK release de l'application Android :

1) Correction locale (si vous préférez construire sur votre machine)

- Erreur courante : "Failed to find Build Tools revision 35.0.0" — il faut installer
  les composants Android correspondants via le SDK Manager.

Commandes (Windows PowerShell) :

```powershell
# Ouvrir le SDK manager (si ANDROID_SDK_ROOT / ANDROID_HOME sont configurés)
& "$env:ANDROID_SDK_ROOT\tools\bin\sdkmanager.bat" "build-tools;35.0.0" "platforms;android-35" "platform-tools"

# Accepter les licences
& "$env:ANDROID_SDK_ROOT\tools\bin\sdkmanager.bat" --licenses

# Puis depuis le dossier apps/mobile
cd apps/mobile
flutter clean
flutter pub get
flutter build apk --release
```

Si vous utilisez Android Studio : ouvrez SDK Manager → SDK Tools → cochez "Show Package Details" → installez Build Tools 35.0.0 et la plateforme Android 35.

2) Méthode CI (recommandée si vous ne voulez pas installer localement)

- Le workflow GitHub Actions est `.github/workflows/android-build.yml`.
- Il se déclenche sur `main` et peut aussi être lancé manuellement depuis l'onglet Actions.
- L'artefact `app-release-apk` sera téléchargeable depuis la page d'exécution du workflow.

Le workflow manuel `.github/workflows/android-apk.yml` permet aussi de générer un APK
sans pousser de commit.

### Signature release

Pour une publication Play Store, ajoutez le fichier local `apps/mobile/android/key.properties`
et un fichier `.jks` privé. Ces deux types de fichiers sont ignorés par Git. Sans ces
secrets, le build CI reste installable pour les tests mais utilise la signature debug.
