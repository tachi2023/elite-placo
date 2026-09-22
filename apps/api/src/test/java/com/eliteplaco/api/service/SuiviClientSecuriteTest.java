package com.eliteplaco.api.service;

import org.junit.jupiter.api.Test;

/**
 * Ce test n'est PAS un test de calcul mais un test de non-régression sur
 * la confidentialité : le point le plus critique du Module 7 est qu'AUCUNE
 * donnée financière ne doit jamais transiter par l'endpoint public
 * /api/suivi/{code} (elite.md §10.15).
 *
 * TODO Phase 6 : une fois ChantierSuiviPublicDTO et le mapping en place,
 * vérifier par réflexion (ou simplement à la lecture du code) que ce DTO
 * ne contient AUCUN champ montant/marge/dépense — voir la classe
 * ChantierSuiviPublicDTO elle-même, volontairement minimaliste.
 */
class SuiviClientSecuriteTest {

    @Test
    void aCompleterEnPhase6() {
        // TODO : test d'intégration MockMvc sur GET /api/suivi/{code}
        // qui vérifie que la réponse JSON ne contient QUE :
        // nomClient, ville, statut, avancementPourcent.
    }
}
