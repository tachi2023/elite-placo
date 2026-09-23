# Elite Placo & Déco — Application de Gestion Comptable des Chantiers

> Fichier de contexte projet. À conserver à la racine du dépôt pour que n'importe quel
> assistant (Claude, Claude Code, etc.) retrouve instantanément l'historique et les
> décisions prises, sans avoir à reposer les mêmes questions.

## 1. Contexte client

| Champ | Valeur |
|---|---|
| Nom commercial | Élite Placo & Déco |
| Entité légale | PRIMA BTP |
| Dirigeant | Raoul Michel |
| Téléphone | +237 688 92 12 13 |
| Email | raoulmichel20@gmail.com |
| Ville | Douala, Cameroun |
| Zone d'activité | Nationale (tout le Cameroun) |
| Secteur | Plafonds en placoplâtre, décoration intérieure, travaux de finition |

Le dirigeant gère plusieurs chantiers en parallèle avec des ouvriers payés sur site. Besoin :
suivre en temps réel la comptabilité de chaque chantier, savoir s'il est rentable, et avoir une
vue globale sur la santé financière de l'entreprise.

Interlocuteur unique pour toute validation : Raoul Michel.

## 2. Périmètre fonctionnel (cahier des charges)

- **Module 1 — Gestion des chantiers** : création, statuts (À venir / En cours / Terminé / En
  pause), modification, archivage, liste temps réel.
- **Module 2 — Suivi financier par chantier** : devis signé, encaissements (acompte / versement /
  solde), dépenses par catégorie (BA13, ossature, visserie, peinture/enduit, transport, main
  d'œuvre, sous-traitant, location matériel, divers), calculs automatiques (total encaissé, total
  dépenses, résultat net, marge brute %, indicateur vert/orange/rouge).
- **Module 3 — Calcul automatique des matériaux** : à partir de la surface (m²) et du système
  choisi (Cornière + Fourrure + BA13 / Rails + Montants + BA13), quantités avec +15% de marge de
  perte, budget estimatif.
- **Module 4 — Tableau de bord global** : CA total, encaissé/dépenses global, résultat net et
  marge globale, résumé par chantier, graphique recettes vs dépenses.
- **Module 5 — Fiche de métrage numérique** : jusqu'à 30 pièces, déductions (poutres, piliers,
  gaines, baies), éléments décoratifs, récapitulatif (surface nette, périmètre), export PDF et
  partage WhatsApp.
- **Module 6 — Suivi des ouvriers** : affectation par chantier, paiements, total main d'œuvre
  remonté automatiquement dans les dépenses du chantier.
- **Module 7 — Site vitrine & espace client** *(extension de périmètre, hors cahier des charges
  initial)* : site public de présentation d'Elite Placo & Déco (accueil, services, réalisations,
  contact), et une page de suivi dédiée à chaque chantier permettant au **client final** (celui qui
  a commandé les travaux, distinct du dirigeant) de consulter l'avancement de son chantier via un
  lien/code unique — sans accès aux données financières internes (montants, marges, dépenses,
  ouvriers).

### Exigences techniques imposées par le cahier des charges

- Plateforme : Android en priorité + version web PC.
- **Fonctionnement hors ligne complet** sur le terrain, avec **synchronisation automatique** au
  retour du réseau.
- **Aucune perte de données** tolérée.
- Accès protégé par mot de passe ou code PIN.
- Export PDF partageable par WhatsApp.
- Toutes les valeurs en FCFA avec séparateur de milliers.
- Charte visuelle : Anthracite `#1E1E1E`, Or `#C9A84C`, Blanc `#F5F5F5`, Vert `#4CAF7D` (bonne
  marge), Orange `#E0B84C` (marge faible), Rouge `#E05555` (perte).

### Livrables attendus (cahier des charges)

Maquettes de tous les écrans → version bêta Android testable → version finale complète →
formation du dirigeant → maintenance et corrections post-livraison.

## 3. Stack technique retenue

**Flutter** (mobile Android + web via Flutter Web) + **Spring Boot** (API REST).

Justification : un seul code source client pour Android et le web (gain de temps vs. natif +
site séparé) ; deux frameworks gratuits/open-source (pas de coût de licence) ; écosystèmes matures
pour le hors-ligne, la sécurité et la synchronisation. Le facteur limitant du projet n'est **pas**
la technologie mais le temps de conception de la synchronisation hors-ligne et le budget alloué.

**Décision : authentification par JWT maison (Spring Security), pas OAuth2.** OAuth2 a été
envisagé puis écarté : il suppose une connexion réseau au moment de l'authentification et un
renouvellement de jeton régulier, ce qui est mal adapté à un usage terrain hors-ligne prolongé
(risque d'expiration du jeton pendant plusieurs jours sans réseau, blocage de la sync au retour).
Il ajoute aussi une complexité disproportionnée pour un utilisateur unique (pas de délégation à un
fournisseur tiers requise). Le verrouillage local par PIN reste indépendant de cette couche API.

### Côté Flutter

| Besoin | Package |
|---|---|
| Base locale (mode hors-ligne) | `sqflite` / `drift` (SQLite) |
| Chiffrement de la base locale | `sqflite_sqlcipher` ou `drift` + SQLCipher |
| Détection réseau | `connectivity_plus` |
| Appels API | `dio` / `http` |
| Stockage sécurisé (PIN, clé de chiffrement) | `flutter_secure_storage` |
| Biométrie (option future) | `local_auth` |
| Génération PDF | `pdf` + `printing` |
| Partage WhatsApp | `share_plus` |
| Gestion d'état | `Provider` / `Riverpod` / `Bloc` |
| Synchronisation en arrière-plan | `workmanager` |
| Version web | Flutter Web (même code source) |

### Côté Spring Boot

- Spring Data JPA + PostgreSQL/MySQL.
- Spring Security + JWT maison (jeton d'accès court + jeton de rafraîchissement) — **pas
  d'OAuth2** (voir décision ci-dessus).
- `BCryptPasswordEncoder` pour les mots de passe serveur.
- API de synchronisation par horodatage/versionnage (transfert des seules données modifiées) —
  **règle de gestion des conflits à définir avant le code** (point ouvert, voir §9).
- Validation stricte des entrées (`@Valid`, DTO dédiés), requêtes paramétrées (protection
  injection SQL), CORS restreint, limitation de débit sur les endpoints sensibles (ex. Bucket4j).
- Journal d'audit des opérations financières critiques, sauvegardes automatiques chiffrées avec
  copie hors site, secrets en variables d'environnement.

### Infrastructure

VPS/cloud pour le serveur Spring Boot, nom de domaine + HTTPS (Let's Encrypt), compte développeur
Google Play, environnements séparés dev/test/prod.

### Site vitrine & espace client (Module 7) — choix d'architecture

Le site vitrine et la page de suivi client sont **publics et consultés par des visiteurs sans
compte** : contrairement à l'application interne du dirigeant, l'enjeu ici est la rapidité
d'affichage et le référencement (SEO), deux points où Flutter Web est structurellement faible
(bundle lourd, contenu peu indexable par les moteurs de recherche). Recommandation : un site web
public **séparé** de l'application Flutter (HTML/CSS/JS classique ou un framework web léger,
ex. Next.js ou simplement des pages servies par le backend), qui appelle la même API Spring Boot
pour récupérer, via le lien/code du chantier, uniquement les données non sensibles nécessaires au
suivi (statut, avancement, dates). Cela ajoute un **composant** au diagramme de composants
existant (`Diagrammes_UML_ElitePlaco.html`) : "Site Vitrine / Portail Client (web public)", relié
au serveur d'application par une interface dédiée `ISuiviClient` distincte de `IAPI`.

## 4. Sécurité (niveau visé)

Proportionné au risque réel (données financières d'une seule entreprise, usage restreint), sans
complexité inutile (pas de multi-rôle ni conformité réglementaire lourde) — mais **non négociables
dès la v1** : chiffrement de la base locale, HTTPS partout, hachage des mots de passe,
verrouillage automatique après inactivité, protection contre les essais de PIN répétés.

## 5. Diagrammes de conception (UML)

Diagrammes déjà produits, conformes au cours de modélisation UML (C. Solnon, INSA Lyon) :

1. Diagramme de cas d'utilisation (acteur Dirigeant + acteur système Réseau)
2. Diagramme de classes (Chantier au centre, héritage `MouvementFinancier` → `Encaissement` /
   `Dépense`, compositions, énumérations du cahier des charges)
3. Diagramme d'états-transitions (cycle de vie du chantier)
4. Diagrammes de séquence : enregistrer un encaissement, calcul des matériaux, synchronisation
   hors-ligne
5. Diagramme d'activité (enregistrement d'une dépense → indicateur vert/orange/rouge)
6. Diagramme de composants
7. Diagramme de déploiement (smartphone Android / PC-navigateur / serveur / base serveur)

→ fichier livré : `Diagrammes_UML_ElitePlaco.html`

## 6. Estimation financière

Le cahier des charges ne fixe aucun budget. Méthode : **coût = (jours-homme × TJM) + coûts
d'infrastructure (année 1) + frais uniques**.

### Effort estimé (jours-homme) — total 60 j-h

Analyse/conception 5 · Architecture 4 · Authentification/sécurité 3 · Gestion chantiers 4 ·
Suivi financier 6 · Calcul matériaux 4 · Fiche de métrage 6 · Suivi ouvriers 3 · Tableau de bord 3 ·
**Hors-ligne + synchronisation 8 (poste le plus lourd)** · Export PDF/WhatsApp 2 · Version web 4 ·
Tests/bêta terrain 6 · Déploiement/formation 2.

### TJM (hypothèses, à confirmer avec le client — non fixé par le cahier des charges)

| Hypothèse | TJM | Main d'œuvre (60 j-h) |
|---|---|---|
| Basse | 15 000 FCFA/j | 900 000 FCFA |
| **Retenue (référence)** | **20 000 FCFA/j** | **1 200 000 FCFA** |
| Haute | 30 000 FCFA/j | 1 800 000 FCFA |

### Infrastructure & licences (année 1)

Hébergement VPS ~96 000 FCFA/an · domaine ~10 000 FCFA/an · HTTPS gratuit (Let's Encrypt) ·
compte développeur Google Play ~15 000 FCFA (unique) · stockage/sauvegardes ~36 000 FCFA/an →
**total infra année 1 : 157 000 FCFA** (puis ~142 000 FCFA/an les années suivantes).

### Coût total estimé — année 1

| Hypothèse | Total |
|---|---|
| Basse | 1 057 000 FCFA |
| **Retenue** | **1 357 000 FCFA** |
| Haute | 1 957 000 FCFA |

→ fichier livré : `Contraintes_Developpement_ElitePlaco.html` (détail complet sécurité + coûts +
planning).

## 7. Planning (démarrage : 1er juillet 2026)

Hypothèse de rythme : 4 jours-homme effectifs/semaine (mi-temps, compatible avec les cours).

| Phase | Contenu | Effort | Période |
|---|---|---|---|
| 1 | Analyse & conception | 5 j-h | 01 → 09 juillet 2026 |
| 2 | Architecture (Spring Boot, Flutter, BDD) | 4 j-h | 10 → 16 juillet 2026 |
| 3 | Authentification & sécurité | 3 j-h | 17 → 21 juillet 2026 |
| 4 | Module Gestion des chantiers | 4 j-h | 22 → 28 juillet 2026 |
| 5 | Module Suivi financier | 6 j-h | 29 juillet → 07 août 2026 |
| 6 | Module Calcul des matériaux | 4 j-h | 08 → 14 août 2026 |
| 7 | Module Fiche de métrage | 6 j-h | 15 → 24 août 2026 |
| 8 | Module Suivi des ouvriers | 3 j-h | 25 → 29 août 2026 |
| 9 | Tableau de bord global | 3 j-h | 30 août → 03 septembre 2026 |
| 10 | **Hors-ligne + synchronisation (critique)** | 8 j-h | 04 → 17 septembre 2026 |
| 11 | Export PDF / WhatsApp | 2 j-h | 18 → 21 septembre 2026 |
| 12 | Version Web (Flutter Web) | 4 j-h | 22 → 28 septembre 2026 |
| 13 | Tests, bêta Android terrain | 6 j-h | 29 sept. → 08 octobre 2026 |
| 14 | Déploiement, formation, livraison | 2 j-h | 09 → 12 octobre 2026 |

**Fin de développement estimée : 12 octobre 2026** — **date cible avec marge de sécurité (+2
semaines) : 26 octobre 2026** (examens, imprévus techniques sur la sync, allers-retours de
validation avec le dirigeant).

## 8. Contraintes organisationnelles

- Interlocuteur unique : Raoul Michel (seul valideur des livrables ; points de validation
  intermédiaires — maquettes, bêta — à planifier avec lui).
- Utilisateur final peu technique, saisie sur chantier : ergonomie prioritaire, formation simple
  prévue à la livraison.
- Zone d'activité nationale : conditions réseau variables à anticiper dès la conception.

## 9. Risques & points ouverts à valider avec le client

- Règle de gestion des conflits de synchronisation (décision 23/09/2026) : détection optimiste
  par horodatage/version serveur, rejet de la modification obsolète avec réponse 409 et mise en
  quarantaine du payload entrant dans l'historique des conflits. Aucun écrasement silencieux :
  l'idempotence par operationId empêche les doublons et le payload conservé permet une résolution
  manuelle ultérieure.
- Qui héberge le serveur sur la durée (développeur ou entreprise).
- Durée/étendue exacte de la maintenance gratuite avant qu'elle ne devienne payante.
- Nombre réel d'utilisateurs/appareils simultanés (cahier des charges décrit un usage par le
  dirigeant seul).
- TJM réellement applicable — les chiffres du §6 sont des hypothèses de calcul, pas un tarif
  contractuel.
- Mécanisme de réinitialisation du PIN (décision 23/09/2026) : l'utilisateur se ré-authentifie
  avec son mot de passe API, puis définit un nouveau PIN local. La biométrie disponible sur le
  terminal reste un second facteur de déverrouillage, sans dépendre d'un fournisseur SMS/email.
- Comportement exact en cas de désarchivage (décision 23/09/2026) : un chantier ARCHIVE revient
  uniquement à TERMINE, reste exclu de la liste active tant qu'il n'est pas explicitement rouvert,
  et chaque désarchivage est journalisé.
- Portée exacte des informations visibles par le client final sur la page de suivi (statut seul,
  ou aussi photos/jalons/dates estimées ?) — à définir avec le dirigeant (Module 7, §10.14-10.16).
- Durée de validité et mode de révocation des liens de suivi client (expiration automatique après
  la fin du chantier, ou accès permanent à l'historique ?).
- Hébergement et nom de domaine du site vitrine : même infrastructure que l'API, ou hébergement
  distinct dédié au contenu public ?

## 10. Scénarios d'utilisation (cas d'usage détaillés)

Scénarios validés un par un avec le client/développeur. Les scénarios **indispensables** (10.1 à
10.9) couvrent l'intégralité des modules du cahier des charges initial ; les scénarios
**secondaires** (10.10 à 10.13) affinent des cas particuliers ; les scénarios **10.14 à 10.16**
couvrent l'extension de périmètre Module 7 (site vitrine & espace client).

### 10.1 — S'authentifier auprès de l'application

**Acteur :** Dirigeant (Raoul Michel)

**Précondition :**
- L'application est installée sur l'appareil (mobile ou web).
- Un code PIN ou un mot de passe a déjà été défini lors de la première utilisation.
- L'application peut fonctionner avec ou sans connexion réseau (l'authentification locale ne dépend pas du réseau).

**Étapes normales :**
1. Le dirigeant ouvre l'application.
2. L'application affiche l'écran de verrouillage demandant le code PIN (ou le mot de passe).
3. Le dirigeant saisit son code PIN.
4. L'application vérifie le code auprès du stockage sécurisé local (`flutter_secure_storage`), sans appel réseau nécessaire.
5. Le code est correct : l'application déverrouille l'accès et affiche le tableau de bord global (Module 4).

**Scénarios alternatifs :**
- **A1 — Code incorrect :** l'application affiche un message d'erreur et propose une nouvelle saisie ; le compteur d'essais est incrémenté.
- **A2 — Trop d'essais échoués :** après un nombre défini d'essais incorrects (ex. 5), l'application bloque temporairement la saisie pendant un délai progressif (protection anti-force-brute).
- **A3 — Première utilisation :** aucun PIN n'existe encore → l'application propose un écran de création de PIN (saisie + confirmation) avant de continuer.
- **A4 — Verrouillage automatique :** si l'application a été mise en arrière-plan au-delà d'un délai d'inactivité, elle redemande le PIN à la reprise, même si la session précédente était active.
- **A5 — PIN oublié :** (point ouvert — voir §9) mécanisme de réinitialisation à préciser, par ex. via le compte administrateur ou en support.

**Postcondition :**
- Le dirigeant est authentifié et a accès à l'ensemble des modules de l'application.
- Une nouvelle tentative d'accès après mise en veille ou fermeture nécessitera une nouvelle authentification.

> **Note technologique :** l'authentification API est assurée par un JWT maison (Spring Security),
> pas par OAuth2 — voir justification au §3.

---

### 10.2 — Créer un nouveau chantier

**Acteur :** Dirigeant

**Précondition :**
- Le dirigeant est authentifié (voir §10.1).
- L'application est ouverte, avec ou sans connexion réseau.

**Étapes normales :**
1. Le dirigeant accède au module "Gestion des chantiers" et sélectionne "Nouveau chantier".
2. L'application affiche un formulaire de création : nom du client, ville, type de travaux, montant du devis signé.
3. Le dirigeant saisit les informations et valide.
4. L'application enregistre le chantier localement (base SQLite) avec le statut par défaut **"À venir"** et une date de création automatique.
5. Le chantier apparaît immédiatement dans la liste des chantiers avec son statut affiché.
6. Si une connexion réseau est disponible, l'enregistrement est synchronisé avec le serveur en arrière-plan ; sinon, il reste en attente de synchronisation (voir §10.12).

**Scénarios alternatifs :**
- **A1 — Champ obligatoire manquant :** si le nom du client ou le type de travaux n'est pas renseigné, l'application affiche un message d'erreur et bloque l'enregistrement tant que le formulaire n'est pas complet.
- **A2 — Montant du devis invalide :** si le montant saisi n'est pas un nombre valide ou est négatif, l'application refuse l'enregistrement et signale le champ en erreur.
- **A3 — Chantier en double (même client, même ville, création rapprochée) :** l'application peut afficher un avertissement non bloquant ("un chantier similaire existe déjà") mais laisse le dirigeant décider de continuer — décision à valider avec lui.
- **A4 — Perte d'application pendant la saisie (fermeture accidentelle) :** aucune donnée n'est perdue tant que le formulaire n'a pas été validé ; rien n'est enregistré si la validation n'a pas eu lieu (comportement attendu, pas une erreur).

**Postcondition :**
- Un nouveau chantier existe dans la base locale avec le statut "À venir".
- Le chantier est visible dans la liste des chantiers et dans le tableau de bord global.
- Le chantier est marqué comme "à synchroniser" si aucun réseau n'était disponible au moment de la création.

---

### 10.3 — Enregistrer un encaissement pour un chantier

**Acteur :** Dirigeant

**Précondition :**
- Le dirigeant est authentifié.
- Le chantier concerné existe déjà dans l'application (statut "À venir" ou "En cours").

**Étapes normales :**
1. Le dirigeant ouvre la fiche du chantier concerné.
2. Il sélectionne "Ajouter un encaissement".
3. L'application affiche un formulaire : montant, date, nature (acompte / versement / solde).
4. Le dirigeant saisit les informations et valide.
5. L'application enregistre l'encaissement localement, rattaché au chantier.
6. L'application recalcule automatiquement : le total encaissé, le reste à encaisser (par rapport au devis signé), le résultat net et la marge brute du chantier.
7. L'indicateur visuel (vert / orange / rouge) est mis à jour et affiché sur la fiche chantier.
8. Si le réseau est disponible, l'encaissement est synchronisé avec le serveur ; sinon il reste en attente de synchronisation.

**Scénarios alternatifs :**
- **A1 — Montant manquant ou invalide (négatif, non numérique) :** l'application refuse l'enregistrement et signale le champ en erreur.
- **A2 — Date manquante ou incohérente (postérieure à aujourd'hui) :** l'application signale l'anomalie ; le dirigeant peut corriger ou confirmer volontairement (règle à valider).
- **A3 — Encaissement supérieur au reste à encaisser :** l'application affiche un avertissement ("le montant dépasse le reste dû") mais peut laisser le dirigeant valider quand même (ex. ajustement de devis) — à confirmer avec lui.
- **A4 — Chantier archivé ou terminé :** si le chantier est déjà "Terminé" et archivé, l'application empêche l'ajout d'un nouvel encaissement, ou demande confirmation explicite avant de rouvrir le chantier — règle à définir.

**Postcondition :**
- L'encaissement est enregistré et rattaché au chantier.
- Les totaux financiers du chantier (et du tableau de bord global) sont à jour.
- L'indicateur de marge reflète la nouvelle situation financière du chantier.

---

### 10.4 — Enregistrer une dépense pour un chantier

**Acteur :** Dirigeant

**Précondition :**
- Le dirigeant est authentifié.
- Le chantier concerné existe déjà dans l'application.

**Étapes normales :**
1. Le dirigeant ouvre la fiche du chantier concerné.
2. Il sélectionne "Ajouter une dépense".
3. L'application affiche un formulaire : montant, date, catégorie (BA13, ossature, visserie, peinture/enduit, transport, main d'œuvre, sous-traitant, location matériel, divers), description.
4. Le dirigeant saisit les informations et valide.
5. L'application enregistre la dépense localement, rattachée au chantier.
6. L'application recalcule automatiquement : le total des dépenses, le résultat net et la marge brute du chantier.
7. L'indicateur visuel (vert / orange / rouge) est mis à jour selon le nouveau résultat.
8. Si le réseau est disponible, la dépense est synchronisée avec le serveur ; sinon elle reste en attente de synchronisation.

**Scénarios alternatifs :**
- **A1 — Montant manquant ou invalide (négatif, non numérique) :** l'application refuse l'enregistrement et signale le champ en erreur.
- **A2 — Catégorie non sélectionnée :** l'application bloque la validation tant qu'une catégorie n'est pas choisie (champ obligatoire pour les calculs et le tableau de bord).
- **A3 — Dépense qui fait passer le chantier en perte :** l'application enregistre normalement la dépense mais affiche immédiatement l'indicateur rouge et peut proposer une alerte visuelle renforcée (à confirmer avec le dirigeant).
- **A4 — Modifier ou supprimer une dépense existante :** voir scénario dédié §10.13.

**Postcondition :**
- La dépense est enregistrée et rattachée au chantier.
- Les totaux financiers du chantier et du tableau de bord global sont à jour.
- L'indicateur de marge reflète la nouvelle situation financière du chantier.

---

### 10.5 — Calculer automatiquement les matériaux nécessaires

**Acteur :** Dirigeant

**Précondition :**
- Le dirigeant est authentifié.
- Le chantier concerné existe déjà dans l'application.

**Étapes normales :**
1. Le dirigeant ouvre la fiche du chantier et sélectionne "Calculer les matériaux".
2. L'application affiche un formulaire : surface en m², choix du système (Cornière + Fourrure + BA13, ou Rails + Montants + BA13).
3. Le dirigeant saisit la surface et choisit le système, puis valide.
4. L'application calcule automatiquement les quantités nécessaires pour chaque matériau du système choisi (plaques BA13, fourrures, cornières, rails, vis placo, vis autophoreuses, bande à joints, enduit).
5. Une marge de perte de +15% est appliquée automatiquement à toutes les quantités.
6. L'application génère et affiche un budget estimatif d'achat des matériaux.
7. Le résultat est rattaché au chantier et consultable à tout moment.

**Scénarios alternatifs :**
- **A1 — Surface non renseignée ou invalide (négative, nulle, non numérique) :** l'application refuse le calcul et signale le champ en erreur.
- **A2 — Aucun système sélectionné :** l'application bloque le calcul tant qu'un système n'est pas choisi (champ obligatoire).
- **A3 — Recalcul après modification de la surface :** si le dirigeant modifie la surface ou change de système après un premier calcul, l'application recalcule entièrement les quantités et le budget, en remplaçant l'ancien résultat (ou en le conservant comme historique — à définir avec le dirigeant).
- **A4 — Prix unitaires des matériaux non définis :** si aucun prix n'a encore été renseigné pour un matériau, l'application affiche les quantités mais indique un budget estimatif incomplet, avec une alerte invitant à compléter les prix.

**Postcondition :**
- Les quantités de matériaux et le budget estimatif sont calculés et rattachés au chantier.
- Le dirigeant peut consulter ce résultat à tout moment depuis la fiche chantier.

---

### 10.6 — Remplir une fiche de métrage numérique

**Acteur :** Dirigeant

**Précondition :**
- Le dirigeant est authentifié.
- Le chantier concerné existe déjà dans l'application.
- Le dirigeant est sur le chantier, avec ou sans connexion réseau.

**Étapes normales :**
1. Le dirigeant ouvre la fiche du chantier et sélectionne "Nouvelle fiche de métrage".
2. Pour chaque pièce (jusqu'à 30), il saisit : nom, longueur, largeur.
3. L'application calcule automatiquement la surface et le périmètre de chaque pièce saisie.
4. Le dirigeant renseigne, si besoin, les déductions (poutres, piliers, gaines, baies) et les éléments décoratifs (décaissé en abord, bandeau horizontal, joue verticale, spot/niche) pour les pièces concernées.
5. L'application calcule le récapitulatif automatique : surface nette totale et périmètre total de la fiche.
6. Le dirigeant valide la fiche.
7. La fiche est enregistrée localement et rattachée au chantier.

**Scénarios alternatifs :**
- **A1 — Longueur ou largeur manquante/invalide pour une pièce :** l'application refuse d'inclure la pièce dans le calcul et signale l'erreur, sans bloquer la saisie des autres pièces.
- **A2 — Tentative d'ajouter une 31e pièce :** l'application bloque l'ajout et affiche un message indiquant la limite de 30 pièces par fiche.
- **A3 — Aucune pièce saisie :** l'application empêche la validation d'une fiche vide (au moins une pièce requise).
- **A4 — Déduction ou élément décoratif avec une valeur incohérente (ex. supérieure à la surface de la pièce) :** l'application affiche un avertissement mais laisse le dirigeant décider de continuer — règle à confirmer.
- **A5 — Modification d'une fiche déjà exportée en PDF :** l'application autorise la modification, mais un nouvel export sera nécessaire pour refléter les changements (l'ancien PDF n'est pas mis à jour rétroactivement).

**Postcondition :**
- La fiche de métrage est enregistrée avec son récapitulatif (surface nette totale, périmètre total) et rattachée au chantier.
- La fiche est prête à être exportée en PDF et partagée par WhatsApp (§10.7).

---

### 10.7 — Exporter une fiche de métrage (ou un bilan de chantier) en PDF et la partager par WhatsApp

**Acteur :** Dirigeant

**Précondition :**
- Le dirigeant est authentifié.
- Une fiche de métrage complète (ou un bilan de chantier) existe pour le chantier concerné.
- L'export PDF ne nécessite pas de connexion réseau (génération locale) ; le partage WhatsApp nécessite que l'application WhatsApp soit installée sur l'appareil.

**Étapes normales :**
1. Le dirigeant ouvre la fiche de métrage (ou le bilan du chantier) déjà enregistrée.
2. Il sélectionne "Exporter en PDF".
3. L'application génère localement un document PDF mis en page (récapitulatif de la fiche ou bilan financier du chantier).
4. L'application propose ensuite l'option "Partager par WhatsApp".
5. Le dirigeant sélectionne cette option ; le système ouvre WhatsApp avec le PDF déjà joint.
6. Le dirigeant choisit le contact ou groupe destinataire et envoie le document.

**Scénarios alternatifs :**
- **A1 — WhatsApp non installé sur l'appareil :** l'application affiche un message informant que WhatsApp est indisponible, et propose une alternative (partage via un autre canal : email, autre application, ou simple enregistrement du PDF sur l'appareil).
- **A2 — Échec de génération du PDF (ex. mémoire insuffisante, fiche corrompue) :** l'application affiche un message d'erreur et propose de réessayer, sans perte des données sources de la fiche.
- **A3 — Fiche incomplète (ex. aucune pièce saisie) :** l'application empêche l'export tant que la fiche ne contient pas au moins les données minimales requises.
- **A4 — Le dirigeant annule le partage après ouverture de WhatsApp :** le PDF généré reste disponible localement (dans les fichiers de l'application) pour un partage ultérieur, sans qu'il soit nécessaire de le régénérer.

**Postcondition :**
- Un fichier PDF de la fiche (ou du bilan) est généré et disponible sur l'appareil.
- Le document a été transmis via WhatsApp si le dirigeant a choisi de le partager.

---

### 10.8 — Affecter un ouvrier à un chantier et enregistrer un paiement

**Acteur :** Dirigeant

**Précondition :**
- Le dirigeant est authentifié.
- Le chantier concerné existe déjà dans l'application.

**Étapes normales :**
1. Le dirigeant ouvre la fiche du chantier et sélectionne "Gérer les ouvriers".
2. Il ajoute un ouvrier (nom, rôle) ou sélectionne un ouvrier déjà connu.
3. L'ouvrier est affecté au chantier.
4. Le dirigeant sélectionne "Enregistrer un paiement" pour cet ouvrier.
5. L'application affiche un formulaire : date, montant, ouvrier concerné (déjà présélectionné).
6. Le dirigeant valide le paiement.
7. L'application enregistre le paiement et recalcule automatiquement le total de la main d'œuvre pour le chantier.
8. Ce total remonte automatiquement dans les dépenses du chantier, et le résultat net / la marge sont recalculés.

**Scénarios alternatifs :**
- **A1 — Nom de l'ouvrier manquant :** l'application refuse l'affectation tant que le nom n'est pas renseigné.
- **A2 — Montant du paiement manquant ou invalide (négatif, non numérique) :** l'application refuse l'enregistrement et signale l'erreur.
- **A3 — Ouvrier affecté à plusieurs chantiers en parallèle :** l'application autorise l'affectation multiple ; chaque paiement reste rattaché au chantier précis pour lequel il a été saisi.
- **A4 — Suppression d'une affectation avec paiements déjà enregistrés :** l'application avertit que des paiements existent et demande confirmation avant de retirer l'ouvrier du chantier — règle à confirmer avec le dirigeant (conserver l'historique ou non).

**Postcondition :**
- L'ouvrier est rattaché au chantier avec son historique de paiements.
- Le total main d'œuvre du chantier est à jour et inclus dans les dépenses globales du chantier.

---

### 10.9 — Changer le statut d'un chantier

**Acteur :** Dirigeant

**Précondition :**
- Le dirigeant est authentifié.
- Le chantier concerné existe déjà dans l'application.

**Étapes normales :**
1. Le dirigeant ouvre la fiche du chantier concerné.
2. Il sélectionne "Changer le statut".
3. L'application propose les transitions possibles selon le statut actuel (ex. depuis "À venir" : passer "En cours" ; depuis "En cours" : passer "En pause" ou "Terminé" ; depuis "En pause" : reprendre "En cours").
4. Le dirigeant choisit le nouveau statut et confirme.
5. L'application met à jour le statut du chantier et l'horodatage du changement.
6. Le nouveau statut est immédiatement reflété dans la liste des chantiers et le tableau de bord global.

**Scénarios alternatifs :**
- **A1 — Tentative de passer directement "À venir" → "Terminé" :** l'application bloque la transition si elle ne respecte pas le cycle de vie prévu (voir diagramme d'états), et affiche les transitions valides.
- **A2 — Passage à "Terminé" alors que le reste à encaisser n'est pas nul :** l'application affiche un avertissement ("solde non soldé") mais peut laisser le dirigeant confirmer quand même — règle à valider avec lui.
- **A3 — Chantier déjà archivé :** l'application empêche tout changement de statut sur un chantier archivé, sauf action explicite de désarchivage (si cette fonctionnalité est prévue — voir §10.10).

**Postcondition :**
- Le statut du chantier est mis à jour et horodaté.
- Le chantier apparaît avec son nouveau statut partout dans l'application (liste, tableau de bord).

---

### 10.10 — Archiver un chantier terminé *(secondaire)*

**Acteur :** Dirigeant

**Précondition :**
- Le dirigeant est authentifié.
- Le chantier concerné a le statut "Terminé".

**Étapes normales :**
1. Le dirigeant ouvre la fiche du chantier terminé.
2. Il sélectionne "Archiver ce chantier".
3. L'application demande une confirmation.
4. Le dirigeant confirme.
5. Le chantier est marqué comme archivé et retiré de la liste principale des chantiers actifs.
6. Le chantier reste consultable dans une liste ou un filtre "Chantiers archivés", avec l'ensemble de son historique (encaissements, dépenses, ouvriers, fiches de métrage).
7. Le chantier continue de compter dans les totaux cumulés du tableau de bord global (chiffre d'affaires, résultat net global).

**Scénarios alternatifs :**
- **A1 — Tentative d'archiver un chantier non terminé :** l'application bloque l'action et indique que seul un chantier "Terminé" peut être archivé.
- **A2 — Annulation avant confirmation :** le dirigeant peut annuler l'archivage à l'étape de confirmation ; aucun changement n'est appliqué.
- **A3 — Désarchivage :** si le dirigeant a besoin de rouvrir un chantier archivé (ex. erreur d'archivage, nouveaux travaux sur le même chantier), l'application propose une action de désarchivage qui remet le chantier dans la liste active — fonctionnalité à confirmer avec le dirigeant, car non explicitement prévue dans le cahier des charges (voir §9).

**Postcondition :**
- Le chantier a le statut "archivé" et n'apparaît plus dans la liste active des chantiers.
- Ses données restent intactes et incluses dans les statistiques globales.

---

### 10.11 — Consulter le tableau de bord global *(secondaire)*

**Acteur :** Dirigeant

**Précondition :**
- Le dirigeant est authentifié.
- Au moins un chantier existe dans l'application (sinon le tableau de bord s'affiche vide).

**Étapes normales :**
1. Le dirigeant ouvre l'application et accède au tableau de bord global (écran d'accueil par défaut après authentification).
2. L'application calcule et affiche : le chiffre d'affaires total (somme de tous les devis signés), le total encaissé et le total des dépenses sur tous les chantiers, le résultat net global et la marge brute globale en %.
3. L'application affiche la liste résumée de tous les chantiers avec leur résultat individuel et leur indicateur (vert / orange / rouge).
4. L'application affiche un graphique comparant recettes et dépenses par chantier.
5. Le dirigeant peut appuyer sur un chantier de la liste pour accéder directement à sa fiche détaillée.

**Scénarios alternatifs :**
- **A1 — Aucun chantier créé :** l'application affiche un tableau de bord vide avec un message invitant à créer un premier chantier.
- **A2 — Données partiellement non synchronisées :** si certains chantiers ont des modifications en attente de synchronisation, le tableau de bord les inclut quand même dans les calculs (les données locales font foi), avec un indicateur discret signalant que tout n'est pas encore synchronisé.
- **A3 — Chantiers archivés :** par défaut, les chantiers archivés restent inclus dans les totaux globaux (CA, résultat net) mais peuvent être exclus de la liste détaillée affichée, ou inclus selon un filtre — à confirmer avec le dirigeant.
- **A4 — Grand nombre de chantiers (performance) :** si la liste devient longue, l'application doit rester fluide (pagination ou défilement) sans ralentir l'affichage sur un appareil mobile d'entrée de gamme.

**Postcondition :**
- Le dirigeant a une vue consolidée et à jour de la santé financière de l'entreprise, sans action de sa part au-delà de l'ouverture de l'écran.

---

### 10.12 — Synchroniser les données après une reprise de connexion réseau *(secondaire — automatique)*

**Acteur :** Réseau (déclencheur automatique) / Application (traitement automatique, sans action du dirigeant)

**Précondition :**
- Le dirigeant a travaillé hors ligne (création/modification de chantiers, encaissements, dépenses, fiches de métrage, paiements) pendant une période sans réseau.
- Ces données sont enregistrées localement et marquées comme "non synchronisées".
- La connexion réseau vient d'être rétablie sur l'appareil.

**Étapes normales :**
1. L'application détecte la reprise de la connexion réseau (via `connectivity_plus`).
2. L'application récupère la liste des données locales non encore synchronisées (chantiers, encaissements, dépenses, fiches, paiements, ouvriers).
3. Pour chaque donnée en attente, l'application l'envoie au serveur via l'API REST sécurisée (HTTPS + jeton JWT).
4. Le serveur enregistre la donnée et renvoie une confirmation.
5. L'application marque localement chaque donnée confirmée comme "synchronisée".
6. Une fois toutes les données envoyées, l'application peut aussi récupérer d'éventuelles mises à jour distantes (si plusieurs appareils sont utilisés) et les intégrer localement.
7. L'indicateur discret de synchronisation (mentionné au tableau de bord) disparaît une fois tout synchronisé.

**Scénarios alternatifs :**
- **A1 — Connexion perdue en cours de synchronisation :** l'application interrompt proprement l'envoi ; les données non confirmées restent marquées "non synchronisées" et seront retentées à la prochaine reprise réseau (aucune donnée n'est perdue ni dupliquée).
- **A2 — Conflit de données (même chantier modifié sur deux appareils) :** **point ouvert non tranché dans le cahier des charges** (voir §9) — règle à définir avec le dirigeant, par exemple "dernière modification gagne" (avec horodatage serveur faisant foi) ou fusion manuelle avec alerte au dirigeant.
- **A3 — Jeton d'authentification expiré pendant la période hors-ligne :** l'application tente un rafraîchissement automatique du jeton ; si celui-ci a également expiré, elle redemande une authentification complète avant de reprendre la synchronisation.
- **A4 — Serveur indisponible (maintenance, panne) :** l'application réessaie automatiquement à intervalles réguliers (avec un délai croissant) sans bloquer l'utilisation hors-ligne de l'application entre-temps.
- **A5 — Volume important de données en attente (plusieurs jours hors-ligne) :** la synchronisation se fait par lots plutôt qu'en un seul envoi massif, pour éviter les timeouts et permettre une reprise partielle en cas d'interruption.

**Postcondition :**
- Toutes les données locales sont reflétées sur le serveur (sauf en cas d'échec réseau persistant, où elles restent en attente).
- L'application signale visuellement l'état "à jour" une fois la synchronisation terminée.

---

### 10.13 — Modifier ou supprimer une dépense (ou un encaissement) déjà enregistrée *(secondaire)*

**Acteur :** Dirigeant

**Précondition :**
- Le dirigeant est authentifié.
- Une dépense (ou un encaissement) existe déjà pour le chantier concerné.

**Étapes normales :**
1. Le dirigeant ouvre la fiche du chantier et accède à la liste des dépenses (ou des encaissements).
2. Il sélectionne l'entrée à modifier ou à supprimer.
3. **Cas modification :** il ajuste le montant, la date, la catégorie ou la description, puis valide.
4. **Cas suppression :** il confirme la suppression de l'entrée.
5. L'application enregistre le changement localement.
6. L'application recalcule automatiquement le total des dépenses (ou encaissements), le résultat net, la marge brute et l'indicateur du chantier.
7. Si le réseau est disponible, la modification/suppression est synchronisée avec le serveur ; sinon elle reste en attente de synchronisation.

**Scénarios alternatifs :**
- **A1 — Nouveau montant invalide (négatif, non numérique) lors d'une modification :** l'application refuse l'enregistrement et signale le champ en erreur, sans toucher à la donnée existante.
- **A2 — Suppression sans confirmation :** l'application exige toujours une confirmation explicite avant suppression, pour éviter une perte accidentelle de données financières.
- **A3 — Entrée déjà synchronisée avec le serveur, modifiée hors ligne :** la modification est appliquée localement immédiatement (le dirigeant voit le résultat tout de suite) et sera transmise au serveur à la prochaine synchronisation ; en cas de conflit avec une modification distante entre-temps, la règle de résolution de conflit générale s'applique (point ouvert, voir §9 et §10.12-A2).
- **A4 — Suppression d'une dépense déjà incluse dans un export PDF existant :** l'export déjà généré n'est pas modifié rétroactivement ; seul un nouvel export reflétera la suppression.
- **A5 — Tentative de modification sur un chantier archivé :** l'application bloque la modification, sauf désarchivage préalable (cohérent avec §10.10).

**Postcondition :**
- La dépense (ou l'encaissement) est mise à jour ou supprimée.
- Les totaux financiers et l'indicateur du chantier reflètent immédiatement le changement.

---

### 10.14 — Générer et transmettre un accès de suivi à un client final pour son chantier *(extension — Module 7)*

**Acteur :** Dirigeant

**Précondition :**
- Le dirigeant est authentifié.
- Le chantier concerné existe déjà dans l'application (statut "À venir" ou "En cours" idéalement).

**Étapes normales :**
1. Le dirigeant ouvre la fiche du chantier concerné.
2. Il sélectionne "Générer un accès client".
3. L'application génère un lien unique (ou un code court) associé exclusivement à ce chantier, sans donner accès aux données financières internes (montants, marges, dépenses).
4. Le dirigeant partage ce lien avec le client final (par WhatsApp, SMS ou email — réutilisation du même mécanisme de partage que pour les PDF).
5. Le client final ouvre le lien depuis le site vitrine et accède à une page de suivi limitée à son seul chantier (§10.15).

**Scénarios alternatifs :**
- **A1 — Chantier archivé :** l'application permet quand même de consulter l'historique de suivi (lien toujours valide en lecture seule), sans possibilité de générer un nouveau lien actif.
- **A2 — Révocation de l'accès :** le dirigeant peut désactiver un lien déjà généré (ex. fin de la relation commerciale, erreur d'envoi) ; le lien devient alors invalide immédiatement.
- **A3 — Génération d'un nouveau lien pour le même chantier :** l'ancien lien est automatiquement invalidé si le dirigeant en régénère un (évite la circulation de plusieurs liens actifs pour un même chantier).
- **A4 — Pas de réseau au moment de la génération :** l'opération nécessite une connexion (le lien doit être enregistré côté serveur pour être consultable publiquement) ; l'application affiche un message indiquant de réessayer une fois en ligne.

**Postcondition :**
- Un lien/code de suivi unique existe pour le chantier, exploitable par le client final.
- Le dirigeant garde la maîtrise de qui peut y accéder (génération/révocation).

---

### 10.15 — Suivre l'avancement de son chantier via le site vitrine *(extension — Module 7)*

**Acteur :** Client final (personne ayant commandé les travaux, distincte du dirigeant)

**Précondition :**
- Le client final dispose d'un lien/code de suivi valide, transmis par le dirigeant (§10.14).
- Une connexion internet est nécessaire côté client (site public, pas de mode hors-ligne côté
  client final).

**Étapes normales :**
1. Le client final ouvre le lien reçu (WhatsApp, SMS ou email) dans son navigateur.
2. Le site vitrine affiche la page de suivi dédiée à son chantier : statut actuel (À venir / En
   cours / En pause / Terminé), avancement, et toute information non sensible convenue avec le
   dirigeant (dates, éventuellement photos — voir point ouvert §9).
3. Aucune donnée financière interne (montants, marges, dépenses, ouvriers) n'est affichée : la vue
   client est strictement limitée à l'avancement.
4. Le client peut consulter cette page à tout moment tant que le lien est valide, sans créer de
   compte.

**Scénarios alternatifs :**
- **A1 — Lien expiré ou révoqué :** message d'erreur clair invitant à contacter Elite Placo &
  Déco pour un nouveau lien.
- **A2 — Chantier passé au statut "Terminé" :** la page affiche un message de fin de chantier
  (et peut inviter le client à laisser un avis ou demander son bilan — option à discuter).
- **A3 — Absence de réseau côté client :** la page est simplement indisponible (dépend de la
  connexion du client, sans mode hors-ligne prévu pour ce public externe).
- **A4 — Chantier archivé :** l'historique de suivi reste accessible en lecture seule (cohérent
  avec §10.14-A1).

**Postcondition :**
- Le client final dispose d'une vue à jour et fiable de l'avancement de son chantier, sans
  exposition des données financières sensibles de l'entreprise.

---

### 10.16 — Consulter le site vitrine *(extension — Module 7)*

**Acteur :** Visiteur (grand public, prospect)

**Précondition :** Aucune — accès public, sans authentification.

**Étapes normales :**
1. Le visiteur accède au site vitrine via son navigateur (nom de domaine public).
2. Le site affiche les pages de présentation : accueil, services (plafonds placoplâtre,
   décoration intérieure, finitions), réalisations/portfolio, coordonnées de contact (téléphone,
   email, zone d'activité nationale).
3. Le visiteur navigue librement entre les pages, sans compte.
4. Le visiteur peut utiliser un formulaire de contact (ou les coordonnées directes) pour solliciter
   un devis.

**Scénarios alternatifs :**
- **A1 — Formulaire de contact incomplet :** validation classique, champs obligatoires signalés
  avant envoi.
- **A2 — Visiteur arrivant via un lien de suivi client :** redirection automatique vers la page de
  suivi dédiée (§10.15) plutôt que vers la page d'accueil générique.
- **A3 — Site indisponible (maintenance, panne serveur) :** une page de maintenance simple est
  affichée, cohérente avec le risque d'indisponibilité serveur déjà identifié (§9).

**Postcondition :**
- Le visiteur a connaissance de l'activité d'Elite Placo & Déco et peut engager un contact
  commercial.

---

## 11. Fichiers de référence déjà produits

- `Diagrammes_UML_ElitePlaco.html` — les 7 diagrammes UML détaillés au §5.
- `Contraintes_Developpement_ElitePlaco.html` — détail complet sécurité, justification techno,
  méthode de calcul des coûts, planning jour par jour.
- `Cahier_des_Charges_ElitePlaco.pdf` — document source fourni par le client.
- `elite.md` (ce fichier) — contexte projet et scénarios d'utilisation validés.
