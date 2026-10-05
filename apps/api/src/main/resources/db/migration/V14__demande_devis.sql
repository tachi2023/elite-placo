CREATE TABLE demande_devis (
    id BIGSERIAL PRIMARY KEY,
    nom VARCHAR(120) NOT NULL,
    email VARCHAR(255),
    telephone VARCHAR(50) NOT NULL,
    ville VARCHAR(120),
    type_travaux VARCHAR(120) NOT NULL,
    superficie VARCHAR(50),
    budget_estime VARCHAR(80),
    message TEXT,
    date_creation TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    statut VARCHAR(30) NOT NULL DEFAULT 'NOUVELLE'
);

CREATE INDEX idx_demande_devis_date_creation ON demande_devis (date_creation DESC);
