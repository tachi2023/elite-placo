package com.eliteplaco.api.service;

import com.eliteplaco.api.dto.DeltaSynchronisationDTO;
import com.eliteplaco.api.repository.AffectationOuvrierRepository;
import com.eliteplaco.api.repository.ChantierRepository;
import com.eliteplaco.api.repository.FicheMetrageRepository;
import com.eliteplaco.api.repository.MouvementFinancierRepository;
import com.eliteplaco.api.repository.OuvrierRepository;
import com.eliteplaco.api.repository.PieceMetrageRepository;
import com.eliteplaco.api.repository.SynchronisationOperationRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class SynchronisationServiceTest {

    @Mock ChantierRepository chantierRepository;
    @Mock MouvementFinancierRepository mouvementRepository;
    @Mock SynchronisationOperationRepository operationRepository;
    @Mock OuvrierRepository ouvrierRepository;
    @Mock AffectationOuvrierRepository affectationRepository;
    @Mock FicheMetrageRepository ficheRepository;
    @Mock PieceMetrageRepository pieceRepository;
    @Mock ChantierService chantierService;
    @Mock FinanceService financeService;
    @Mock OuvrierService ouvrierService;
    @Mock MetrageService metrageService;

    @InjectMocks SynchronisationService synchronisationService;

    @Test
    void deltaInclutLesQuatreCollectionsTerrain() {
        when(chantierRepository.findAll()).thenReturn(java.util.List.of());
        when(mouvementRepository.findAll()).thenReturn(java.util.List.of());
        when(ouvrierRepository.findAll()).thenReturn(java.util.List.of());
        when(affectationRepository.findAll()).thenReturn(java.util.List.of());
        when(ficheRepository.findAll()).thenReturn(java.util.List.of());
        when(pieceRepository.findAll()).thenReturn(java.util.List.of());

        DeltaSynchronisationDTO delta = synchronisationService.renvoyerDeltaServeur(null);

        assertTrue(delta.ouvriers().isEmpty());
        assertTrue(delta.affectationsOuvriers().isEmpty());
        assertTrue(delta.fichesMetrage().isEmpty());
        assertTrue(delta.piecesMetrage().isEmpty());
    }
}
