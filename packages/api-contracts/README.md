# Contrats API partagés

Les clients Web et Flutter consomment la même API Spring Boot. Les DTO Java restent la source de
vérité serveur ; ce dossier documente les conventions qui doivent rester stables entre les clients.

## Règles

- les routes publiques et authentifiées sont documentées dans `apps/api` ;
- les réponses d'erreur utilisent le format `{code, message, details}` ;
- les dates sont transmises au format ISO-8601 ;
- les montants sont en FCFA et transmis comme nombres JSON ;
- les opérations de synchronisation portent un `operationId` unique et peuvent être rejouées ;
- le delta utilise un curseur `serveurDate` renvoyé par l'API.

Toute modification cassante doit être introduite sous `/api/v2` plutôt que de modifier silencieusement
le contrat utilisé par l'application mobile déjà installée.
