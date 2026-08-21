# Déploiement & vérification — Élite Placo & Déco

Ce fichier rassemble les commandes et étapes pour déployer le projet sur Render, tester le mode démo, construire l'APK, et vérifier la conteneurisation locale.

## 1) Prérequis
- Compte Git avec dépôt connecté à Render.
- Render linked to your repository (services defined in `render.yaml`).
- Docker Desktop (pour tests locaux).
- Java 17, Maven, Node, Flutter (pour builds locaux si nécessaire).

## 2) Commit / Push des changements (déjà modifiés : `render.yaml`, backend, scripts)
```bash
git add backend/pom.xml backend/src/main/java/com/eliteplaco/api/controller/SuiviClientController.java \
  render.yaml scripts/build_apk.ps1 docs/DEMO.md README_DEPLOY.md
git commit -m "Enable demo endpoint, move H2 to local profile, add APK script and demo docs"
git push origin main
```

## 3) Déploiement sur Render
- Sur le Dashboard Render, vérifiez que les services existent : `elite-placo-api`, `elite-placo-site`.
- Confirm that `render.yaml` variables are applied; in particular ensure `APP_DEMO_ENABLED=true` is present for the `elite-placo-api` service.
- Render déclenche automatiquement une build après le push si le repo est connecté.
- Sur Render, surveillez les logs de build et runtime (Dashboard → service → Logs).

## 4) URLs publiques attendues (vérifiez votre Dashboard pour URLs exactes)
- Front (site vitrine) : https://elite-placo-site.onrender.com
- API : https://elite-placo-api.onrender.com

## 5) Tester le mode démo (après déploiement)
- Endpoint JSON demo :
```bash
curl -s https://elite-placo-api.onrender.com/api/suivi/DEMO-CLIENT | jq
```
- Page client (navigateur) :

https://elite-placo-site.onrender.com/suivi/DEMO-CLIENT

Le mode démo renvoie des données factices seulement si `APP_DEMO_ENABLED=true`.

## 6) Construire l'APK local (Windows PowerShell)
```powershell
# depuis la racine du repo
.\scripts\build_apk.ps1 -buildMode release
# APK produit : frontend\build\app\outputs\flutter-apk\app-release.apk
```

## 7) Conteneurisation locale (vérifier avant le push)
1. Assurez-vous que Docker Desktop est démarré.
2. Si erreurs DNS lors du pull d'images : Docker Desktop → Settings → Docker Engine → ajouter `"dns": ["8.8.8.8"]` puis Restart.
3. Prépuller images si nécessaire :
```powershell
docker pull maven:3.9.8-eclipse-temurin-17
docker pull node:20-alpine
docker pull nginx:alpine
docker pull cirrusci/flutter:stable
```
4. Build & start :
```powershell
docker compose build
docker compose up -d
```
5. Vérifiez services :
```powershell
docker compose ps
# tester API demo en local
curl http://localhost:8080/api/suivi/DEMO-CLIENT
```

## 8) Checklist sécurité (À exécuter avant mise en production finale)
- [ ] Retirer `APP_DEMO_ENABLED` ou le mettre à `false` en production.
- [ ] S'assurer que la dépendance H2 n'est active qu'en local (profil `local`) — `pom.xml` modifié.
- [ ] Revenir les relaxations dans `SecurityConfig` (ne pas laisser `actuator/**` ouvert en prod).
- [ ] JWT secret : stocker via secret manager/env var solide; ne pas utiliser valeurs par défaut.
- [ ] HTTPS obligatoire (Render fournit TLS) ; rediriger HTTP → HTTPS.
- [ ] Limiter CORS uniquement aux origines nécessaires.
- [ ] Audit des endpoints qui modifient des données financières.

## 9) Rollback rapide
- Depuis Render Dashboard, redeploy previous successful deploy (Render -> service -> Deploys -> rollback to previous).
- Ou `git revert <sha>` puis push pour forcer une nouvelle build.

## 10) Support & debug
- Logs Backend : Render Dashboard → `elite-placo-api` → Logs
- Logs Front : Render Dashboard → `elite-placo-site` → Logs
- Pour problèmes réseau/Docker local : `docker logs <container>` & `docker run --rm busybox nslookup production.cloudfront.docker.com`

---
Gardez-moi en copie si vous souhaitez que j'exécute le `git push` pour vous, ou si vous voulez que j'automatise le pipeline (ex : GitHub Actions) pour déployer automatiquement sur Render. Je peux aussi générer les pages admin+client pour le frontend dès que vous confirmez la priorité.