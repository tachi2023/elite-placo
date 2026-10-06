CREATE TABLE IF NOT EXISTS photo_chantier (
    id BIGSERIAL PRIMARY KEY,
    chantier_id BIGINT NOT NULL,
    url VARCHAR(1000) NOT NULL,
    public_id VARCHAR(255),
    libelle VARCHAR(255),
    avant_apres VARCHAR(20),
    visible_client BOOLEAN NOT NULL DEFAULT TRUE,
    date_creation TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_photo_chantier FOREIGN KEY (chantier_id) REFERENCES chantier (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS document_chantier (
    id BIGSERIAL PRIMARY KEY,
    chantier_id BIGINT NOT NULL,
    url VARCHAR(1000) NOT NULL,
    public_id VARCHAR(255),
    libelle VARCHAR(255),
    visible_client BOOLEAN NOT NULL DEFAULT TRUE,
    date_creation TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_document_chantier FOREIGN KEY (chantier_id) REFERENCES chantier (id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_photo_chantier_chantier_id ON photo_chantier (chantier_id);
CREATE INDEX IF NOT EXISTS idx_document_chantier_chantier_id ON document_chantier (chantier_id);
