-- V1 contenait un hash de documentation inutilisable. Cette correction rend
-- l'installation initiale testable ; le mot de passe doit être changé avant
-- toute mise en production publique.
UPDATE utilisateur
SET mot_de_passe_hache = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'
WHERE identifiant = 'raoul.michel'
  AND mot_de_passe_hache = '$2a$10$REMPLACER_PAR_UN_HASH_BCRYPT_REEL';
