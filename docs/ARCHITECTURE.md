# Architecture cible

## Frontières

`apps/api` ne dépend jamais du code des clients. Il expose les règles métier, la sécurité, les
migrations et les contrats HTTP.

`apps/mobile` est le client opérationnel du dirigeant. Il peut écrire dans son cache local sans
réseau puis pousser sa file d'actions dès que la connexion revient.

`apps/web` est le canal public. Il privilégie le référencement, le chargement rapide et le suivi
client limité aux informations non sensibles.

## Choix de migration

Le code métier Flutter existant conserve Provider comme gestion d'état unique. Une migration vers
une autre bibliothèque ne serait pas une amélioration structurelle immédiate et risquerait de
casser le fonctionnement hors ligne. Le découpage actuel `models / providers / repositories /`
`services / screens` est conservé dans `apps/mobile/lib` et documenté avant une migration future
par fonctionnalité.

Le backend conserve son architecture Spring standard `controller -> service -> repository -> entity`
avec DTO dédiés et migrations Flyway versionnées.

## Environnements

- `local` : H2 ou Docker PostgreSQL, ports API `8081`, site `3000`, Flutter Web `5000` ;
- `staging` : services Render séparés, données de test isolées ;
- `production` : PostgreSQL managé, secrets Render, HTTPS et CORS limité aux domaines connus.

Les secrets, fichiers `.env`, payloads de test avec mots de passe et logs d'exécution ne doivent
jamais être commités.
