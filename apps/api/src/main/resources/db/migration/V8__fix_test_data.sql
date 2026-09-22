-- Delete test data if exists
DELETE FROM piece_metrage WHERE fiche_metrage_id IN (SELECT id FROM fiche_metrage WHERE chantier_id IN (SELECT id FROM chantier WHERE code_acces_client IN ('VB-2026-014', 'HM-2026-009', 'SC-2025-041', 'RB-2026-022', 'SP-2026-007', 'RE-2025-038')));
DELETE FROM fiche_metrage WHERE chantier_id IN (SELECT id FROM chantier WHERE code_acces_client IN ('VB-2026-014', 'HM-2026-009', 'SC-2025-041', 'RB-2026-022', 'SP-2026-007', 'RE-2025-038'));
DELETE FROM affectation_ouvrier WHERE chantier_id IN (SELECT id FROM chantier WHERE code_acces_client IN ('VB-2026-014', 'HM-2026-009', 'SC-2025-041', 'RB-2026-022', 'SP-2026-007', 'RE-2025-038'));
DELETE FROM mouvement_financier WHERE chantier_id IN (SELECT id FROM chantier WHERE code_acces_client IN ('VB-2026-014', 'HM-2026-009', 'SC-2025-041', 'RB-2026-022', 'SP-2026-007', 'RE-2025-038'));
DELETE FROM lien_suivi_client WHERE chantier_id IN (SELECT id FROM chantier WHERE code_acces_client IN ('VB-2026-014', 'HM-2026-009', 'SC-2025-041', 'RB-2026-022', 'SP-2026-007', 'RE-2025-038'));
DELETE FROM chantier WHERE code_acces_client IN ('VB-2026-014', 'HM-2026-009', 'SC-2025-041', 'RB-2026-022', 'SP-2026-007', 'RE-2025-038');
DELETE FROM ouvrier WHERE telephone IN ('+237 677 11 22 33', '+237 655 44 55 66', '+237 699 77 88 99', '+237 690 12 34 56');

-- Reset sequences
SELECT setval('chantier_id_seq', COALESCE((SELECT MAX(id) FROM chantier), 1));
SELECT setval('mouvement_financier_id_seq', COALESCE((SELECT MAX(id) FROM mouvement_financier), 1));
SELECT setval('ouvrier_id_seq', COALESCE((SELECT MAX(id) FROM ouvrier), 1));
SELECT setval('affectation_ouvrier_id_seq', COALESCE((SELECT MAX(id) FROM affectation_ouvrier), 1));
SELECT setval('fiche_metrage_id_seq', COALESCE((SELECT MAX(id) FROM fiche_metrage), 1));
SELECT setval('piece_metrage_id_seq', COALESCE((SELECT MAX(id) FROM piece_metrage), 1));
SELECT setval('lien_suivi_client_id_seq', COALESCE((SELECT MAX(id) FROM lien_suivi_client), 1));
