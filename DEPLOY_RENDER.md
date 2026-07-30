# Déploiement sur Render — instructions

## 1) Connecter le dépôt

- Connectez votre compte GitHub à Render.
- Créez un nouveau service à partir du dépôt GitHub `tachi2023/elite-placo`.
- Sélectionnez le blueprint Render si vous souhaitez utiliser le fichier [render.yaml](render.yaml).

## 2) Déploiement automatique

Pour déclencher un déploiement à chaque push sur `main`, ajoutez dans GitHub Actions la secret :

- `RENDER_DEPLOY_HOOK_URL`

La workflow [`.github/workflows/deploy-render.yml`](.github/workflows/deploy-render.yml) l’utilisera automatiquement.

## 3) Variables d’environnement

Vérifiez les variables suivantes dans Render :

- `JWT_SECRET`
- `CORS_ORIGINS`
- `VITE_API_URL`

## 4) Base PostgreSQL

Render créera la base de données via [render.yaml](render.yaml). Si vous préférez une autre base, vous pouvez la remplacer à la main.

## 5) Vérification

Une fois déployé :

- le backend est disponible sur l’URL Render fournie,
- le site public est disponible sur l’URL Render fournie,
- l’APK peut être téléchargé depuis Actions GitHub.
