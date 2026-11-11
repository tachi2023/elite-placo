package com.eliteplaco.api.service;

import com.eliteplaco.api.entity.CategorieDepense;
import com.eliteplaco.api.entity.Chantier;
import com.eliteplaco.api.entity.Depense;
import com.eliteplaco.api.exception.AppException;
import com.eliteplaco.api.repository.ChantierRepository;
import com.eliteplaco.api.repository.MouvementFinancierRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class FinanceServiceTest {

    @Mock MouvementFinancierRepository mouvementRepository;
    @Mock ChantierRepository chantierRepository;
    @Mock ChantierService chantierService;
    @Mock AuditService auditService;

    private FinanceService service;
    private Chantier chantier;

    @BeforeEach
    void setUp() {
        service = new FinanceService(mouvementRepository, chantierRepository,
                chantierService, auditService);
        chantier = new Chantier();
        chantier.setId(7L);
    }

    @Test
    void depenseValideEstEnregistreeAvecSaCategorie() {
        when(chantierService.trouverParIdOuLever(7L)).thenReturn(chantier);
        when(mouvementRepository.save(any(Depense.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        Depense depense = service.enregistrerDepense(
                7L, BigDecimal.valueOf(80_000), LocalDate.now().minusDays(1),
                CategorieDepense.MATERIAUX_BA13, "Plaques");

        assertEquals(BigDecimal.valueOf(80_000), depense.getMontant());
        assertEquals(CategorieDepense.MATERIAUX_BA13, depense.getCategorie());
    }

    @Test
    void montantNegatifDateFutureEtCategorieManquanteSontRefuses() {
        assertThrows(AppException.class, () -> service.enregistrerDepense(
                7L, BigDecimal.valueOf(-1), LocalDate.now(),
                CategorieDepense.DIVERS, "Erreur"));
        assertThrows(AppException.class, () -> service.enregistrerDepense(
                7L, BigDecimal.valueOf(1), LocalDate.now().plusDays(1),
                CategorieDepense.DIVERS, "Erreur"));
        assertThrows(AppException.class, () -> service.enregistrerDepense(
                7L, BigDecimal.ONE, LocalDate.now(), null, "Sans catégorie"));
    }
}
