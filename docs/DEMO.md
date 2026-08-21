# Mode Démo et Accès Public

Ce document explique comment activer l'accès démo public et obtenir un lien de test pour l'espace client.

## Activer le mode démo
Sur le serveur (Render) ou en local, définir la variable d'environnement :

- `APP_DEMO_ENABLED=true`

Dans Render, ajoutez la variable à `envVars` pour le service `elite-placo-api`.

## Lien de test (client public)
Lorsque `APP_DEMO_ENABLED=true`, utilisez le code de suivi `DEMO-CLIENT` :

- URL de démonstration (exemple) : `https://<votre-site>/suivi/DEMO-CLIENT`

Sur le backend l'endpoint public `/api/suivi/DEMO-CLIENT` renverra des données factices
permettant d'admirer le design sans base de données.

## Notes de sécurité
- Le mode démo ne donne aucun accès admin et n'expose pas d'informations sensibles. Il sert uniquement
pour la démonstration visuelle.
- En production, retirez `APP_DEMO_ENABLED` ou mettez-la à `false`.
