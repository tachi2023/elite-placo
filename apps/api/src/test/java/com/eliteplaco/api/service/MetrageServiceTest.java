package com.eliteplaco.api.service;

import com.eliteplaco.api.dto.PieceMetrageRequest;
import com.eliteplaco.api.entity.Chantier;
import com.eliteplaco.api.entity.FicheMetrage;
import com.eliteplaco.api.entity.PieceMetrage;
import com.eliteplaco.api.repository.FicheMetrageRepository;
import com.eliteplaco.api.exception.AppException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class MetrageServiceTest {

    @Mock FicheMetrageRepository ficheRepository;
    @Mock ChantierService chantierService;

    private MetrageService service;
    private FicheMetrage fiche;

    @BeforeEach
    void setUp() {
        service = new MetrageService(ficheRepository, chantierService);
        Chantier chantier = new Chantier();
        chantier.setId(7L);
        fiche = new FicheMetrage();
        fiche.setId(3L);
        fiche.setChantier(chantier);
        fiche.setSysteme(FicheMetrage.SystemePlatrerie.CORNIERE_FOURRURE_BA13);
        when(ficheRepository.findById(3L)).thenReturn(Optional.of(fiche));
    }

    @Test
    void refuseUneFicheVideLorsDeLaValidation() {
        assertThrows(AppException.class, () -> service.valider(7L, 3L));
    }

    @Test
    void refuseLaTrenteEtUniemePiece() {
        for (int i = 0; i < 30; i++) {
            PieceMetrage piece = new PieceMetrage();
            piece.setLongueur(BigDecimal.ONE);
            piece.setLargeur(BigDecimal.ONE);
            fiche.getPieces().add(piece);
        }

        assertThrows(AppException.class, () -> service.ajouterPiece(
                7L, 3L, new PieceMetrageRequest("Pièce 31", BigDecimal.ONE, BigDecimal.ONE, BigDecimal.ZERO)));
    }

    @Test
    void refuseUneDeductionNegativeEtSignaleUneDeductionTropGrande() {
        assertThrows(AppException.class, () -> service.ajouterPiece(
                7L, 3L, new PieceMetrageRequest("Salon", BigDecimal.ONE, BigDecimal.ONE,
                        BigDecimal.valueOf(-0.1))));

        PieceMetrage piece = new PieceMetrage();
        piece.setLongueur(BigDecimal.ONE);
        piece.setLargeur(BigDecimal.ONE);
        piece.setSurfaceDeduction(BigDecimal.valueOf(1.2));
        fiche.getPieces().add(piece);
        assertTrue(service.deductionDepasseSurface(piece));
        assertEquals(BigDecimal.ZERO, service.surfaceNetteTotale(fiche));
    }
}
