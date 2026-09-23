ALTER TABLE ouvrier
    ADD COLUMN IF NOT EXISTS synchronise BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE ouvrier
    ADD COLUMN IF NOT EXISTS last_modified_date TIMESTAMP NOT NULL DEFAULT now();

ALTER TABLE affectation_ouvrier
    ADD COLUMN IF NOT EXISTS last_modified_date TIMESTAMP NOT NULL DEFAULT now();
ALTER TABLE fiche_metrage
    ADD COLUMN IF NOT EXISTS last_modified_date TIMESTAMP NOT NULL DEFAULT now();
ALTER TABLE piece_metrage
    ADD COLUMN IF NOT EXISTS synchronise BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE piece_metrage
    ADD COLUMN IF NOT EXISTS last_modified_date TIMESTAMP NOT NULL DEFAULT now();

CREATE INDEX IF NOT EXISTS idx_ouvrier_last_modified ON ouvrier(last_modified_date);
CREATE INDEX IF NOT EXISTS idx_affectation_last_modified ON affectation_ouvrier(last_modified_date);
CREATE INDEX IF NOT EXISTS idx_fiche_last_modified ON fiche_metrage(last_modified_date);
CREATE INDEX IF NOT EXISTS idx_piece_last_modified ON piece_metrage(last_modified_date);
