CREATE TABLE IF NOT EXISTS audit (
    id BIGSERIAL PRIMARY KEY,
    date_heure TIMESTAMP NOT NULL,
    utilisateur VARCHAR(120) NOT NULL,
    action VARCHAR(80) NOT NULL,
    entite VARCHAR(80) NOT NULL,
    entite_id BIGINT,
    chantier_id BIGINT,
    details VARCHAR(2000)
);

CREATE INDEX IF NOT EXISTS idx_audit_chantier_date
    ON audit (chantier_id, date_heure DESC);

CREATE INDEX IF NOT EXISTS idx_audit_action_date
    ON audit (action, date_heure DESC);
