package com.eliteplaco.api.service;

import com.eliteplaco.api.dto.QuantiteMateriauDTO;
import com.eliteplaco.api.dto.ResultatMateriauxDTO;
import com.eliteplaco.api.entity.FicheMetrage;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class MateriauxServiceTest {

    private final MateriauxService service = new MateriauxService();

    @Test
    void arronditChaqueQuantiteAuNombreEntierSuperieur() {
        ResultatMateriauxDTO resultat = service.calculer(
                10.1,
                FicheMetrage.SystemePlatrerie.CORNIERE_FOURRURE_BA13,
                null,
                prixComplets());

        assertTrue(resultat.lignes().stream()
                .allMatch(ligne -> ligne.quantite() == Math.ceil(ligne.quantite())));
        assertEquals(5.0, ligne(resultat, "Bande à joints").quantite());
        assertEquals(4.0, ligne(resultat, "Enduit de jointoiement").quantite());
    }

    @Test
    void budgetResteIncompletSiUnPrixManque() {
        ResultatMateriauxDTO resultat = service.calculer(
                20,
                FicheMetrage.SystemePlatrerie.RAILS_MONTANTS_BA13,
                null,
                Map.of("ba13", BigDecimal.valueOf(5000)));

        assertTrue(resultat.budgetIncomplet());
        assertEquals(null, resultat.budgetTotal());
    }

    private Map<String, BigDecimal> prixComplets() {
        return Map.of(
                "ba13", BigDecimal.valueOf(5000),
                "fourrure", BigDecimal.valueOf(2500),
                "corniere", BigDecimal.valueOf(2000),
                "rail", BigDecimal.valueOf(3000),
                "montant", BigDecimal.valueOf(3500),
                "vis_placo", BigDecimal.valueOf(25),
                "vis_autoforeuse", BigDecimal.valueOf(20),
                "bande_joint", BigDecimal.valueOf(500),
                "enduit", BigDecimal.valueOf(1000));
    }

    private QuantiteMateriauDTO ligne(ResultatMateriauxDTO resultat, String nom) {
        return resultat.lignes().stream()
                .filter(ligne -> ligne.nomMateriau().equals(nom))
                .findFirst()
                .orElseThrow();
    }
}
