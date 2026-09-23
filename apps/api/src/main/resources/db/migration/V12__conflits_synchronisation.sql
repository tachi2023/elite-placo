CREATE TABLE IF NOT EXISTS conflit_synchronisation (
    id BIGSERIAL PRIMARY KEY,
    operation_id VARCHAR(120) NOT NULL UNIQUE,
    entite VARCHAR(60) NOT NULL,
    action VARCHAR(60) NOT NULL,
    local_id BIGINT,
    payload_json TEXT NOT NULL,
    message VARCHAR(500) NOT NULL,
    statut VARCHAR(20) NOT NULL DEFAULT 'OUVERT'
        CHECK (statut IN ('OUVERT', 'RESOLU', 'IGNORE')),
    date_creation TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_conflit_statut_date
    ON conflit_synchronisation(statut, date_creation DESC);
