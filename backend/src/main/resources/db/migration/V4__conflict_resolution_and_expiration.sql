-- V4 — Résolution de conflits par horodatage (last_modified_date)
-- et date d'expiration pour les liens de suivi client.

-- Ajout de la colonne last_modified_date sur la table chantier
ALTER TABLE chantier ADD COLUMN last_modified_date TIMESTAMP NOT NULL DEFAULT now();

-- Ajout de la colonne date_expiration sur la table lien_suivi_client
ALTER TABLE lien_suivi_client ADD COLUMN date_expiration TIMESTAMP;
