package com.eliteplaco.api.service;

import com.eliteplaco.api.dto.CreerAvisClientRequest;
import com.eliteplaco.api.entity.AvisClient;
import com.eliteplaco.api.entity.Chantier;
import com.eliteplaco.api.entity.LienSuiviClient;
import com.eliteplaco.api.repository.AvisClientRepository;
import com.eliteplaco.api.repository.LienSuiviClientRepository;
import org.junit.jupiter.api.Test;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class AvisClientServiceTest {

    @Test
    void commentaireValideEstMisEnAttente() {
        AvisClientRepository avisRepository = mock(AvisClientRepository.class);
        LienSuiviClientRepository lienRepository = mock(LienSuiviClientRepository.class);
        Chantier chantier = new Chantier();
        chantier.setId(12L);
        LienSuiviClient lien = new LienSuiviClient();
        lien.setChantier(chantier);
        when(lienRepository.findByCodePublicAndActifTrue("ABCD1234")).thenReturn(Optional.of(lien));
        when(avisRepository.save(any(AvisClient.class))).thenAnswer(invocation -> invocation.getArgument(0));

        var result = new AvisClientService(avisRepository, lienRepository).creer(
                new CreerAvisClientRequest("ABCD1234", "Marie", 5, "Très bon travail."));

        assertEquals(AvisClient.Statut.EN_ATTENTE, result.statut());
        assertEquals(12L, result.chantierId());
    }
}
