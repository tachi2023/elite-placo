package com.eliteplaco.api.service;

import com.eliteplaco.api.entity.AffectationOuvrier;
import com.eliteplaco.api.entity.Chantier;
import com.eliteplaco.api.entity.Ouvrier;
import com.eliteplaco.api.exception.AppException;
import com.eliteplaco.api.repository.AffectationOuvrierRepository;
import com.eliteplaco.api.repository.OuvrierRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class OuvrierServiceTest {

    @Mock OuvrierRepository ouvrierRepository;
    @Mock AffectationOuvrierRepository affectationRepository;
    @Mock FinanceService financeService;
    @Mock ChantierService chantierService;

    private OuvrierService service;
    private Ouvrier ouvrier;
    private Chantier chantier;

    @BeforeEach
    void setUp() {
        service = new OuvrierService(ouvrierRepository, affectationRepository,
                financeService, chantierService);
        ouvrier = new Ouvrier();
        ouvrier.setId(4L);
        ouvrier.setNomComplet("Jean Test");
        chantier = new Chantier();
        chantier.setId(7L);
    }

    @Test
    void paiementCreeUneDepenseMainOeuvreAutomatique() {
        LocalDate date = LocalDate.now().minusDays(1);
        when(ouvrierRepository.findById(4L)).thenReturn(Optional.of(ouvrier));
        when(chantierService.trouverParIdOuLever(7L)).thenReturn(chantier);
        when(affectationRepository.save(any(AffectationOuvrier.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        AffectationOuvrier resultat = service.enregistrerPaiement(
                4L, 7L, BigDecimal.valueOf(125_000), date);

        assertEquals(BigDecimal.valueOf(125_000), resultat.getMontantPaye());
        verify(financeService).enregistrerDepense(
                eq(7L), eq(BigDecimal.valueOf(125_000)), eq(date),
                eq(com.eliteplaco.api.entity.CategorieDepense.MAIN_OEUVRE),
                eq("Paiement Jean Test (généré automatiquement)"));
    }

    @Test
    void montantInvalideNeCreeAucuneEcriture() {
        assertThrows(AppException.class, () -> service.enregistrerPaiement(
                4L, 7L, BigDecimal.ZERO, LocalDate.now()));

        verifyNoInteractions(ouvrierRepository, affectationRepository,
                financeService, chantierService);
    }

    @Test
    void dateFutureEstRefusee() {
        assertThrows(AppException.class, () -> service.enregistrerPaiement(
                4L, 7L, BigDecimal.valueOf(1000), LocalDate.now().plusDays(1)));

        verifyNoInteractions(ouvrierRepository, affectationRepository,
                financeService, chantierService);
    }
}
