package com.eliteplaco.api.service;

import com.eliteplaco.api.dto.ChantierSuiviPublicDTO;
import com.eliteplaco.api.entity.ContenuSite;
import org.junit.jupiter.api.Test;

import java.lang.reflect.Field;
import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Non-régression pour le Module 7 : les données publiques ne doivent jamais
 * exposer les montants financiers internes ni les autres détails sensibles.
 */
class SuiviClientSecuriteTest {

    @Test
    void leDTOPublicNeContientQueLesChampsAutorises() {
        List<String> champs = Arrays.stream(ChantierSuiviPublicDTO.class.getDeclaredFields())
                .map(Field::getName)
                .toList();

        assertEquals(List.of("nomClient", "ville", "statut", "avancementPourcent", "etapes", "photos", "documents"), champs);
        assertFalse(champs.stream().anyMatch(name -> name.contains("montant") || name.contains("encaisse") || name.contains("depense") || name.contains("marge")));
    }

    @Test
    void leSitePublieAccepteLesTypesDeContenuRequis() {
        assertDoesNotThrow(() -> ContenuSite.TypeContenu.valueOf("PROJET"));
        assertDoesNotThrow(() -> ContenuSite.TypeContenu.valueOf("A_PROPOS"));
    }
}
