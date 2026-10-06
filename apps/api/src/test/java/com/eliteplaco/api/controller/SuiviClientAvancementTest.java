package com.eliteplaco.api.controller;

import com.eliteplaco.api.entity.Chantier;
import com.eliteplaco.api.entity.EtapeChantier;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

class SuiviClientAvancementTest {
    @Test
    void avancementEstLeRatioDesEtapesTerminees() {
        Chantier chantier = new Chantier();
        EtapeChantier terminee = etape(EtapeChantier.StatutEtape.TERMINEE);
        EtapeChantier enCours = etape(EtapeChantier.StatutEtape.EN_COURS);
        EtapeChantier aFaire = etape(EtapeChantier.StatutEtape.A_FAIRE);

        assertEquals(33, SuiviClientController.calculerAvancementPublic(chantier,
                List.of(terminee, enCours, aFaire)));
    }

    private EtapeChantier etape(EtapeChantier.StatutEtape statut) {
        EtapeChantier etape = new EtapeChantier();
        etape.setStatut(statut);
        return etape;
    }
}
