-- Version serveur des mouvements pour le pull delta hors-ligne.
ALTER TABLE mouvement_financier
    ADD COLUMN last_modified_date TIMESTAMP NOT NULL DEFAULT now();

CREATE INDEX idx_mouvement_last_modified
    ON mouvement_financier(last_modified_date);
