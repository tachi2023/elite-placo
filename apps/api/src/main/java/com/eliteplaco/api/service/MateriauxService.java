package com.eliteplaco.api.service;

import com.eliteplaco.api.dto.QuantiteMateriauDTO;
import com.eliteplaco.api.dto.ResultatMateriauxDTO;
import com.eliteplaco.api.entity.FicheMetrage;
import com.eliteplaco.api.exception.AppException;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Module 3 — calcul automatique des matériaux à partir de la surface et du
 * système choisi, avec +15% de marge de perte (elite.md §2 ; §10.5).
 *
 * ⚠️ Les coefficients ci-dessous (espacement des fourrures/montants,
 * couverture d'une plaque BA13, consommation de vis/enduit au m²) sont des
 * VALEURS DE CHANTIER STANDARD, non fixées par le cahier des charges. À
 * FAIRE VALIDER avec le dirigeant avant tout usage réel — identiques à
 * celles utilisées côté Flutter (Script 6) pour rester cohérentes.
 */
@Service
public class MateriauxService {

    private static final double MARGE_PERTE = 1.15; // +15%, imposé par le cahier des charges

    private static final double LONGUEUR_PLAQUE_BA13 = 2.60;
    private static final double LARGEUR_PLAQUE_BA13 = 1.20;
    private static final double SURFACE_PLAQUE = LONGUEUR_PLAQUE_BA13 * LARGEUR_PLAQUE_BA13; // 3.12 m²

    private static final double LONGUEUR_BARRE_FOURRURE_MONTANT = 4.0; // m
    private static final double LONGUEUR_BARRE_RAIL_CORNIERE = 3.0;    // m
    private static final double ESPACEMENT_ENTRAXE = 0.60;              // m
    private static final double VIS_PLACO_PAR_M2 = 25;
    private static final double VIS_AUTOFOREUSE_PAR_M2 = 10;
    private static final double ML_BANDE_JOINT_PAR_M2 = 0.4;
    private static final double KG_ENDUIT_PAR_M2 = 0.3;

    public ResultatMateriauxDTO calculer(double surfaceM2, FicheMetrage.SystemePlatrerie systeme,
                                          Double perimetreM, Map<String, BigDecimal> prixUnitaires) {
        if (surfaceM2 <= 0) {
            throw new AppException("La surface doit être un nombre positif.");
        }
        if (systeme == null) {
            throw new AppException("Choisissez un système de plâtrerie.");
        }
        Map<String, BigDecimal> prix = prixUnitaires == null ? Map.of() : prixUnitaires;

        double perimetre = perimetreM != null ? perimetreM : Math.sqrt(surfaceM2) * 4;

        List<QuantiteMateriauDTO> lignes = new ArrayList<>();
        lignes.add(new QuantiteMateriauDTO(
                "Plaques BA13 (2,60 × 1,20 m)",
                Math.ceil(avecMarge(surfaceM2 / SURFACE_PLAQUE)), "plaque", prix.get("ba13")));

        if (systeme == FicheMetrage.SystemePlatrerie.CORNIERE_FOURRURE_BA13) {
            double mlFourrure = avecMarge(surfaceM2 / ESPACEMENT_ENTRAXE);
            double nbFourrures = Math.ceil(mlFourrure / LONGUEUR_BARRE_FOURRURE_MONTANT);
            double nbCornieres = Math.ceil(avecMarge(perimetre / LONGUEUR_BARRE_RAIL_CORNIERE));

            lignes.add(new QuantiteMateriauDTO("Fourrures (barres de 4 m)", nbFourrures, "barre", prix.get("fourrure")));
            lignes.add(new QuantiteMateriauDTO("Cornières (barres de 3 m)", nbCornieres, "barre", prix.get("corniere")));
        } else {
            double mlRails = avecMarge(perimetre * 2);
            double nbRails = Math.ceil(mlRails / LONGUEUR_BARRE_RAIL_CORNIERE);
            double nbMontants = Math.ceil(avecMarge(perimetre / ESPACEMENT_ENTRAXE));

            lignes.add(new QuantiteMateriauDTO("Rails (barres de 3 m)", nbRails, "barre", prix.get("rail")));
            lignes.add(new QuantiteMateriauDTO("Montants (barres de 4 m)", nbMontants, "barre", prix.get("montant")));
        }

        lignes.add(new QuantiteMateriauDTO("Vis placo", Math.ceil(avecMarge(surfaceM2 * VIS_PLACO_PAR_M2)), "unité", prix.get("vis_placo")));
        lignes.add(new QuantiteMateriauDTO("Vis autoforeuses", Math.ceil(avecMarge(surfaceM2 * VIS_AUTOFOREUSE_PAR_M2)), "unité", prix.get("vis_autoforeuse")));
        lignes.add(new QuantiteMateriauDTO("Bande à joints", avecMarge(surfaceM2 * ML_BANDE_JOINT_PAR_M2), "ml", prix.get("bande_joint")));
        lignes.add(new QuantiteMateriauDTO("Enduit de jointoiement", avecMarge(surfaceM2 * KG_ENDUIT_PAR_M2), "kg", prix.get("enduit")));

        boolean incomplet = lignes.stream().anyMatch(l -> l.prixUnitaire() == null);
        BigDecimal total = incomplet ? null : lignes.stream()
                .map(QuantiteMateriauDTO::sousTotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        return new ResultatMateriauxDTO(systeme.name(), surfaceM2, lignes, total, incomplet);
    }

    /** Réutilise la surface nette + périmètre déjà calculés d'une fiche de métrage validée (Module 5). */
    public ResultatMateriauxDTO calculerDepuisFiche(FicheMetrage fiche, Map<String, BigDecimal> prixUnitaires) {
        if (fiche.getPieces().isEmpty()) {
            throw new AppException("La fiche de métrage ne contient aucune pièce.");
        }
        double surfaceNette = fiche.getPieces().stream()
                .mapToDouble(p -> Math.max(0, (p.getLongueur().doubleValue() * p.getLargeur().doubleValue()) - p.getSurfaceDeduction().doubleValue()))
                .sum();
        double perimetre = fiche.getPieces().stream()
                .mapToDouble(p -> 2 * (p.getLongueur().doubleValue() + p.getLargeur().doubleValue()))
                .sum();

        return calculer(surfaceNette, fiche.getSysteme(), perimetre, prixUnitaires);
    }

    private double avecMarge(double valeur) {
        return valeur * MARGE_PERTE;
    }
}
