CREATE TABLE IF NOT EXISTS etape_chantier (
    id BIGSERIAL PRIMARY KEY,
    chantier_id BIGINT NOT NULL,
    libelle VARCHAR(120) NOT NULL,
    ordre INTEGER NOT NULL,
    statut VARCHAR(20) NOT NULL DEFAULT 'A_FAIRE',
    date_fin TIMESTAMP NULL,
    CONSTRAINT fk_etape_chantier FOREIGN KEY (chantier_id) REFERENCES chantier (id) ON DELETE CASCADE,
    CONSTRAINT uq_etape_chantier_ordre UNIQUE (chantier_id, ordre)
);

CREATE INDEX IF NOT EXISTS idx_etape_chantier_chantier_id ON etape_chantier (chantier_id);
