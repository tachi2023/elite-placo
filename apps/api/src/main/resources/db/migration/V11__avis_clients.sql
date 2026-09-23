CREATE TABLE IF NOT EXISTS avis_client (
    id BIGSERIAL PRIMARY KEY,
    chantier_id BIGINT NOT NULL REFERENCES chantier(id),
    nom_client VARCHAR(120) NOT NULL,
    note INTEGER NOT NULL CHECK (note BETWEEN 1 AND 5),
    commentaire VARCHAR(1200) NOT NULL,
    statut VARCHAR(20) NOT NULL DEFAULT 'EN_ATTENTE'
        CHECK (statut IN ('EN_ATTENTE', 'APPROUVE', 'REJETE')),
    date_creation TIMESTAMP NOT NULL DEFAULT now(),
    date_publication TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_avis_publication
    ON avis_client(statut, date_publication DESC);
