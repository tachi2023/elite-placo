CREATE TABLE contenu_site (
    id SERIAL PRIMARY KEY,
    type VARCHAR(50) NOT NULL,
    cle VARCHAR(100),
    titre VARCHAR(255),
    description TEXT,
    image_url VARCHAR(500),
    ordre INTEGER
);

-- Insertion des données par défaut pour que le site vitrine continue de fonctionner

-- SERVICES
INSERT INTO contenu_site (type, cle, titre, description, image_url, ordre) VALUES
('SERVICE', 'service_1', 'Faux Plafonds', 'Création de faux plafonds en BA13, démontables ou décoratifs. Isolation thermique et phonique optimale avec finitions parfaites.', NULL, 1),
('SERVICE', 'service_2', 'Cloisons & Doublages', 'Distribution de l''espace et isolation thermique. Solutions hydrofuges pour pièces humides et haute dureté pour zones de passage.', NULL, 2),
('SERVICE', 'service_3', 'Décoration & Staff', 'Corniches, moulures, rosaces et éléments décoratifs sur mesure. Un habillage élégant pour sublimer votre intérieur.', NULL, 3);

-- REALISATIONS
INSERT INTO contenu_site (type, cle, titre, description, image_url, ordre) VALUES
('REALISATIONS', 'realisation_1', 'Villa Moderne - Yaoundé', 'Aménagement complet en BA13 avec éclairage indirect', '/images/realisation_villa.jpg', 1),
('REALISATIONS', 'realisation_2', 'Bureaux Corporate - Douala', 'Faux plafonds démontables et cloisons acoustiques', '/images/realisation_corporate.jpg', 2),
('REALISATIONS', 'realisation_3', 'Hôtel de Luxe - Kribi', 'Décoration en staff et corniches lumineuses', '/images/realisation_hotel.jpg', 3),
('REALISATIONS', 'realisation_4', 'Résidence Privée - Bafoussam', 'Meubles TV sur mesure en plaques de plâtre', '/images/realisation_residence.jpg', 4);
