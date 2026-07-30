# Déploiement sur Render — instructions

1) Lier le dépôt GitHub à Render

- Connectez votre compte GitHub dans Render
- Créez un service Web pour le backend, choisissez le dossier `backend`
  - Build Command: `mvn -DskipTests package`
  - Start Command: `java -jar target/api-0.1.0-MVP.jar`
  - Définissez les variables d'environnement à partir de `.env.render.sample`

- Créez un service Static Site pour le site-vitrine, dossier `site-vitrine`
  - Build Command: `npm ci && npm run build`
  - Publish directory: `dist`
  - Définissez `VITE_API_URL` pour pointer sur l'URL publique du backend Render

2) Base de données

- Provisionnez une base PostgreSQL (Render propose des add-ons gérés) ou utilisez un service externe
- Ensuite, exécutez les migrations Flyway sur la base (Render permet d'exécuter des commandes via la console ou d'exécuter un job temporaire)

Exemple de commande Flyway (depuis le container ou local si accès réseau):

```
mvn -pl backend org.flywaydb:flyway-maven-plugin:migrate \
  -Dflyway.url=jdbc:postgresql://$DB_HOST:$DB_PORT/$DB_NAME \
  -Dflyway.user=$DB_USER -Dflyway.password=$DB_PASSWORD
```

3) Tests post-déploiement

- Vérifiez que `https://<backend>/actuator/health` (si activé) est OK
- Accédez à la page publique `https://<site-vitrine>` et testez un code de suivi
