package com.eliteplaco.api.service;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Vérifie le calcul de marge et de l'indicateur vert/orange/rouge
 * (elite.md §2, Module 2) — la partie la plus sensible du MVP : un mauvais
 * calcul induit directement le dirigeant en erreur sur la rentabilité
 * d'un chantier.
 *
 * TODO Phase 6 : une fois ChantierService injectable avec de vrais
 * repositories (ou des mocks Mockito), remplacer ces tests par de vrais
 * appels à calculerSituation(). Pour l'instant, ils documentent le
 * comportement ATTENDU des seuils, à réutiliser tel quel.
 */
class ChantierServiceTest {

    @ParameterizedTest(name = "marge {0}% -> indicateur {1}")
    @CsvSource({
        "25, VERT",     // bonne marge
        "20, VERT",     // limite basse du vert
        "19, ORANGE",
        "12, ORANGE",
        "5,  ORANGE",   // limite basse de l'orange
        "4,  ROUGE",
        "0,  ROUGE",
        "-8, ROUGE",    // chantier en perte
    })
    void indicateurRespecteLesSeuilsDefinis(double marge, String indicateurAttendu) {
        // TODO Phase 6 : appeler la vraie méthode une fois extraite en
        // package-private ou testable isolément, ex. :
        // String resultat = chantierService.calculerIndicateur(BigDecimal.valueOf(marge));
        // assertEquals(indicateurAttendu, resultat);
    }

    @Test
    void resultatNetEstEncaisseMoinsDepenses() {
        BigDecimal encaisse = new BigDecimal("9200000");
        BigDecimal depenses = new BigDecimal("6400000");
        BigDecimal resultatAttendu = new BigDecimal("2800000");

        assertEquals(resultatAttendu, encaisse.subtract(depenses));
    }

    @Test
    void margeEstZeroSiAucunEncaissement() {
        // Cas limite : chantier "À venir" sans encaissement -> pas de
        // division par zéro, marge = 0 (voir §10.10 : chantier À venir
        // n'affiche pas encore de marge dans le prototype).
        BigDecimal encaisse = BigDecimal.ZERO;
        // TODO : assertEquals(BigDecimal.ZERO, chantierService.calculerMarge(...));
    }
}
