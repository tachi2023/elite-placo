-- ============================================================================
-- Schéma initial — Élite Placo & Déco (MVP)
-- Reprend le modèle SINGLE_TABLE (MouvementFinancier -> Encaissement/Depense)
-- ============================================================================

CREATE TABLE utilisateur (
    id                BIGSERIAL PRIMARY KEY,
    identifiant       VARCHAR(100) NOT NULL UNIQUE,
    mot_de_passe_hache VARCHAR(255) NOT NULL
);

CREATE TABLE chantier (
    id                 BIGSERIAL PRIMARY KEY,
    nom_client         VARCHAR(150) NOT NULL,
    ville              VARCHAR(100),
    type_travaux       VARCHAR(150),
    statut             VARCHAR(20) NOT NULL DEFAULT 'A_VENIR'
                        CHECK (statut IN ('A_VENIR','EN_COURS','EN_PAUSE','TERMINE','ARCHIVE')),
    montant_devis      NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (montant_devis >= 0),
    code_acces_client  VARCHAR(50),
    date_creation      TIMESTAMP NOT NULL DEFAULT now()
);

-- Table unique pour Encaissement + Depense (héritage SINGLE_TABLE)
CREATE TABLE mouvement_financier (
    id              BIGSERIAL PRIMARY KEY,
    type_mouvement  VARCHAR(20) NOT NULL CHECK (type_mouvement IN ('ENCAISSEMENT','DEPENSE')),
    date            DATE NOT NULL,
    montant         NUMERIC(12,2) NOT NULL CHECK (montant > 0),
    chantier_id     BIGINT NOT NULL REFERENCES chantier(id) ON DELETE CASCADE,

    -- Champs propres à Encaissement (NULL pour une Depense)
    nature          VARCHAR(50),

    -- Champs propres à Depense (NULL pour un Encaissement)
    categorie       VARCHAR(30)
                    CHECK (categorie IN ('MATERIAUX_BA13','PROFILES_OSSATURE','VISSERIE',
                                          'PEINTURE_ENDUIT','TRANSPORT','MAIN_OEUVRE',
                                          'SOUS_TRAITANT','LOCATION_MATERIEL','DIVERS')),
    description     TEXT
);

-- Index sur les colonnes fréquemment recherchées (perf. tableau de bord / fiche chantier)
CREATE INDEX idx_mouvement_chantier ON mouvement_financier(chantier_id);
CREATE INDEX idx_chantier_statut ON chantier(statut);

-- Donnée de test minimale pour vérifier que le schéma fonctionne
INSERT INTO utilisateur (identifiant, mot_de_passe_hache)
VALUES ('raoul.michel', '$2a$10$REMPLACER_PAR_UN_HASH_BCRYPT_REEL');
