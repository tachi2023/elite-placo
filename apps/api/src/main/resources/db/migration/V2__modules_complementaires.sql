-- ============================================================================
-- V2 — Tables complémentaires : ouvriers (Module 6), fiche de métrage
-- (Module 5), accès de suivi client (Module 7), colonne de synchronisation
-- hors-ligne (exigence technique §2 du cahier des charges).
-- ============================================================================

-- ---- Module 6 : suivi des ouvriers -----------------------------------------
CREATE TABLE ouvrier (
    id              BIGSERIAL PRIMARY KEY,
    nom_complet     VARCHAR(150) NOT NULL,
    telephone       VARCHAR(30),
    date_creation   TIMESTAMP NOT NULL DEFAULT now()
);

-- Affectation d'un ouvrier à un chantier + paiements associés.
-- Le total remonte automatiquement dans les dépenses "main d'œuvre" du
-- chantier (recalcul fait côté service, voir OuvrierService).
CREATE TABLE affectation_ouvrier (
    id              BIGSERIAL PRIMARY KEY,
    ouvrier_id      BIGINT NOT NULL REFERENCES ouvrier(id) ON DELETE CASCADE,
    chantier_id     BIGINT NOT NULL REFERENCES chantier(id) ON DELETE CASCADE,
    montant_paye    NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (montant_paye >= 0),
    date_paiement   DATE NOT NULL,
    synchronise     BOOLEAN NOT NULL DEFAULT true
);

-- ---- Module 5 : fiche de métrage numérique ---------------------------------
CREATE TABLE fiche_metrage (
    id              BIGSERIAL PRIMARY KEY,
    chantier_id     BIGINT NOT NULL REFERENCES chantier(id) ON DELETE CASCADE,
    systeme         VARCHAR(40) NOT NULL
                    CHECK (systeme IN ('CORNIERE_FOURRURE_BA13','RAILS_MONTANTS_BA13')),
    surface_nette   NUMERIC(10,2),
    perimetre_total NUMERIC(10,2),
    date_creation   TIMESTAMP NOT NULL DEFAULT now(),
    synchronise     BOOLEAN NOT NULL DEFAULT true
);

-- Jusqu'à 30 pièces par fiche (limite gérée côté application, pas en base).
CREATE TABLE piece_metrage (
    id                  BIGSERIAL PRIMARY KEY,
    fiche_metrage_id    BIGINT NOT NULL REFERENCES fiche_metrage(id) ON DELETE CASCADE,
    nom_piece           VARCHAR(100) NOT NULL,
    longueur            NUMERIC(6,2) NOT NULL CHECK (longueur > 0),
    largeur             NUMERIC(6,2) NOT NULL CHECK (largeur > 0),
    surface_deduction   NUMERIC(6,2) NOT NULL DEFAULT 0,  -- poutres, piliers, gaines, baies
    ordre               INTEGER NOT NULL DEFAULT 1
);

-- ---- Module 7 : accès de suivi pour le client final ------------------------
-- Un seul lien ACTIF à la fois par chantier (§10.14-A3 : la régénération
-- invalide automatiquement l'ancien lien — logique gérée côté service).
CREATE TABLE lien_suivi_client (
    id              BIGSERIAL PRIMARY KEY,
    chantier_id     BIGINT NOT NULL REFERENCES chantier(id) ON DELETE CASCADE,
    code_public     VARCHAR(20) NOT NULL UNIQUE,
    actif           BOOLEAN NOT NULL DEFAULT true,
    date_creation   TIMESTAMP NOT NULL DEFAULT now(),
    date_revocation TIMESTAMP
);

-- ---- Exigence technique : marquage hors-ligne -------------------------------
-- Chaque table modifiable depuis le terrain doit savoir ce qui reste à
-- envoyer au serveur (voir Architecture_Technique_ElitePlaco.md, §"Marquage
-- des données en attente").
ALTER TABLE chantier            ADD COLUMN synchronise BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE mouvement_financier ADD COLUMN synchronise BOOLEAN NOT NULL DEFAULT true;

-- ---- Index de performance ---------------------------------------------------
CREATE INDEX idx_affectation_chantier   ON affectation_ouvrier(chantier_id);
CREATE INDEX idx_affectation_ouvrier    ON affectation_ouvrier(ouvrier_id);
CREATE INDEX idx_fiche_metrage_chantier ON fiche_metrage(chantier_id);
CREATE INDEX idx_piece_fiche            ON piece_metrage(fiche_metrage_id);
CREATE INDEX idx_lien_code              ON lien_suivi_client(code_public);
CREATE INDEX idx_lien_chantier_actif    ON lien_suivi_client(chantier_id, actif);
CREATE INDEX idx_chantier_non_sync      ON chantier(synchronise) WHERE synchronise = false;
CREATE INDEX idx_mouvement_non_sync     ON mouvement_financier(synchronise) WHERE synchronise = false;
