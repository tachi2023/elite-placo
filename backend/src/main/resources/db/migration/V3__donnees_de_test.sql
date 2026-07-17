-- ============================================================================
-- V3 — Données de test réalistes, cohérentes avec les scénarios validés
-- dans elite.md et le prototype d'interfaces (§10.x).
-- À NE PAS exécuter en production : réservé aux environnements dev/test.
-- ============================================================================

-- ---- Chantiers (6, comme dans le tableau de bord de démonstration) --------
INSERT INTO chantier (nom_client, ville, type_travaux, statut, montant_devis, code_acces_client) VALUES
('Villa Bonanjo',           'Douala', 'Plâtrerie + décoration intérieure', 'EN_COURS', 15800000, 'VB-2026-014'),
('Hôtel Le Méridien',       'Douala', 'Faux plafonds + revêtements muraux', 'EN_COURS', 26000000, 'HM-2026-009'),
('Siège Corporate',         'Akwa',   'Plâtrerie + peinture décorative',    'TERMINE',   9500000, 'SC-2025-041'),
('Résidence Bonapriso',     'Douala', 'Décoration intérieure',              'A_VENIR',  11200000, 'RB-2026-022'),
('Suite Présidentielle',    'Kribi',  'Faux plafonds décoratifs',           'EN_PAUSE',  8200000, 'SP-2026-007'),
('Restaurant Étoile',       'Bonanjo','Plâtrerie + isolation',              'TERMINE',   6900000, 'RE-2025-038');

-- ---- Mouvements financiers (encaissements + dépenses, table SINGLE_TABLE) --
-- Chantier 1 : Villa Bonanjo
INSERT INTO mouvement_financier (type_mouvement, date, montant, chantier_id, nature) VALUES
('ENCAISSEMENT', '2026-03-15', 4500000, 1, 'ACOMPTE'),
('ENCAISSEMENT', '2026-05-02', 3200000, 1, 'VERSEMENT'),
('ENCAISSEMENT', '2026-06-20', 1500000, 1, 'VERSEMENT');
INSERT INTO mouvement_financier (type_mouvement, date, montant, chantier_id, categorie, description) VALUES
('DEPENSE', '2026-03-18', 2100000, 1, 'MATERIAUX_BA13',      'Livraison plaques BA13 + ossature'),
('DEPENSE', '2026-04-02', 2300000, 1, 'MAIN_OEUVRE',          'Paiement équipe pose (2 ouvriers)'),
('DEPENSE', '2026-05-10',  900000, 1, 'PEINTURE_ENDUIT',      'Enduit de finition et peinture'),
('DEPENSE', '2026-05-20',  450000, 1, 'TRANSPORT',            'Transport matériaux Douala-chantier'),
('DEPENSE', '2026-06-05',  650000, 1, 'LOCATION_MATERIEL',    'Location échafaudage 3 semaines');

-- Chantier 2 : Hôtel Le Méridien
INSERT INTO mouvement_financier (type_mouvement, date, montant, chantier_id, nature) VALUES
('ENCAISSEMENT', '2026-02-10', 8000000, 2, 'ACOMPTE'),
('ENCAISSEMENT', '2026-04-15', 6000000, 2, 'VERSEMENT');
INSERT INTO mouvement_financier (type_mouvement, date, montant, chantier_id, categorie, description) VALUES
('DEPENSE', '2026-02-20', 4200000, 2, 'MATERIAUX_BA13',   'Plaques hydrofuges suites'),
('DEPENSE', '2026-03-15', 5100000, 2, 'MAIN_OEUVRE',       'Équipe renforcée 4 ouvriers'),
('DEPENSE', '2026-04-20', 1800000, 2, 'SOUS_TRAITANT',     'Électricien pour spots encastrés'),
('DEPENSE', '2026-05-01', 1000000, 2, 'DIVERS',            'Imprévus chantier');

-- Chantier 3 : Siège Corporate (terminé)
INSERT INTO mouvement_financier (type_mouvement, date, montant, chantier_id, nature) VALUES
('ENCAISSEMENT', '2025-11-05', 7800000, 3, 'SOLDE');
INSERT INTO mouvement_financier (type_mouvement, date, montant, chantier_id, categorie, description) VALUES
('DEPENSE', '2025-10-10', 3200000, 3, 'MATERIAUX_BA13', 'Fournitures plâtrerie'),
('DEPENSE', '2025-10-25', 2440000, 3, 'MAIN_OEUVRE',    'Main d''œuvre chantier complet');

-- Chantier 5 : Suite Présidentielle (en pause, marge négative)
INSERT INTO mouvement_financier (type_mouvement, date, montant, chantier_id, nature) VALUES
('ENCAISSEMENT', '2026-01-20', 3500000, 5, 'ACOMPTE');
INSERT INTO mouvement_financier (type_mouvement, date, montant, chantier_id, categorie, description) VALUES
('DEPENSE', '2026-02-01', 2600000, 5, 'MATERIAUX_BA13', 'Matériaux spécifiques suite dorée'),
('DEPENSE', '2026-02-15', 1300000, 5, 'MAIN_OEUVRE',    'Main d''œuvre avant mise en pause');

-- ---- Ouvriers et affectations -----------------------------------------------
INSERT INTO ouvrier (nom_complet, telephone) VALUES
('Emmanuel Ateba', '+237 677 11 22 33'),
('Paul Ondoa',      '+237 655 44 55 66'),
('Serge Mballa',    '+237 699 77 88 99'),
('Josué Fouda',     '+237 690 12 34 56');

INSERT INTO affectation_ouvrier (ouvrier_id, chantier_id, montant_paye, date_paiement) VALUES
(1, 1, 780000, '2026-06-01'),
(3, 1, 640000, '2026-06-01'),
(2, 2, 1120000, '2026-05-01'),
(4, 2, 980000, '2026-05-01');

-- ---- Fiche de métrage (Villa Bonanjo) ---------------------------------------
INSERT INTO fiche_metrage (chantier_id, systeme, surface_nette, perimetre_total) VALUES
(1, 'RAILS_MONTANTS_BA13', 71.3, 96.8);

INSERT INTO piece_metrage (fiche_metrage_id, nom_piece, longueur, largeur, surface_deduction, ordre) VALUES
(1, 'Salon',                   7.20, 4.50, 0.0, 1),
(1, 'Chambre principale',      4.80, 3.77, 0.0, 2),
(1, 'Cuisine',                 4.10, 3.56, 0.0, 3),
(1, 'Couloir',                 6.20, 1.00, 0.9, 4);

-- ---- Liens de suivi client (Module 7) ---------------------------------------
INSERT INTO lien_suivi_client (chantier_id, code_public, actif) VALUES
(1, 'VB-2026-014', true),
(2, 'HM-2026-009', true),
(4, 'RB-2026-022', true),
(5, 'SP-2026-007', true);

-- ---- Utilisateur de démonstration (mot de passe à re-générer en dev !) -----
-- Le hash ci-dessous correspond au mot de passe "changeme" — À REMPLACER
-- avant tout usage réel (voir BCryptPasswordEncoder dans le backend).
UPDATE utilisateur
SET mot_de_passe_hache = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'
WHERE identifiant = 'raoul.michel';
