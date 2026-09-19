CREATE TABLE synchronisation_operation (
    id BIGSERIAL PRIMARY KEY,
    operation_id VARCHAR(120) NOT NULL UNIQUE,
    succes BOOLEAN NOT NULL,
    serveur_id BIGINT,
    message VARCHAR(500)
);
