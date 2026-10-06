ALTER TABLE contenu_site ADD COLUMN IF NOT EXISTS visible BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE contenu_site ADD COLUMN IF NOT EXISTS public_id VARCHAR(255);

INSERT INTO contenu_site (type, cle, titre, description, image_url, ordre, visible)
SELECT 'PROJET', 'projet_expertise', 'Une expertise maîtrisée',
       'De la conception à la livraison, chaque chantier est suivi avec exigence et rigueur.', NULL, 2, TRUE
WHERE NOT EXISTS (SELECT 1 FROM contenu_site WHERE type = 'PROJET' AND cle = 'projet_expertise');

INSERT INTO contenu_site (type, cle, titre, description, image_url, ordre, visible)
SELECT 'A_PROPOS', 'apropos_intro', 'Élite Placo & Déco',
       'Une équipe spécialisée dans les faux plafonds, les finitions, les cloisons et la décoration intérieure sur mesure.', NULL, 3, TRUE
WHERE NOT EXISTS (SELECT 1 FROM contenu_site WHERE type = 'A_PROPOS' AND cle = 'apropos_intro');
