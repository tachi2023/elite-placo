package com.eliteplaco.api.service;

import com.eliteplaco.api.entity.Chantier;
import com.eliteplaco.api.repository.ChantierRepository;
import com.eliteplaco.api.repository.EtapeChantierRepository;
import com.eliteplaco.api.repository.LienSuiviClientRepository;
import com.eliteplaco.api.repository.MouvementFinancierRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * Vérifie le calcul de marge et de l'indicateur vert/orange/rouge
 * (elite.md §2, Module 2) — la partie la plus sensible du MVP : un mauvais
 * calcul induit directement le dirigeant en erreur sur la rentabilité
 * d'un chantier.
 */
@ExtendWith(MockitoExtension.class)
class ChantierServiceTest {

    @Mock ChantierRepository chantierRepository;
    @Mock MouvementFinancierRepository mouvementRepository;
    @Mock LienSuiviClientRepository lienSuiviClientRepository;
    @Mock AuditService auditService;
    @Mock EtapeChantierRepository etapeRepository;

    private ChantierService chantierService;

    @org.junit.jupiter.api.BeforeEach
    void setUp() {
        chantierService = new ChantierService(
                chantierRepository,
                mouvementRepository,
                lienSuiviClientRepository,
                auditService,
                etapeRepository);
    }

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
        assertEquals(indicateurAttendu,
                chantierService.calculerIndicateur(BigDecimal.valueOf(marge)));
    }

    @Test
    void resultatNetEstEncaisseMoinsDepenses() {
        Chantier chantier = chantier("Client test", BigDecimal.valueOf(10_000_000));

        var situation = chantierService.calculerSituation(
                chantier,
                new BigDecimal("9200000"),
                new BigDecimal("6400000"));

        assertEquals(new BigDecimal("2800000"), situation.resultatNet());
        assertEquals(new BigDecimal("30.4300"), situation.margeBrutePourcent());
        assertEquals("VERT", situation.indicateur());
    }

    @Test
    void margeEstZeroSiAucunEncaissement() {
        Chantier chantier = chantier("Client test", BigDecimal.ZERO);

        var situation = chantierService.calculerSituation(
                chantier, BigDecimal.ZERO, BigDecimal.ZERO);

        assertEquals(BigDecimal.ZERO, situation.margeBrutePourcent());
        assertEquals("ROUGE", situation.indicateur());
    }

    @Test
    void refuseUneModificationAvecUneVersionClientTropAncienne() {
        Chantier chantier = chantier("Client conflit", BigDecimal.valueOf(500_000));
        chantier.setId(7L);
        chantier.setStatut(Chantier.StatutChantier.EN_COURS);
        chantier.setLastModifiedDate(LocalDateTime.of(2026, 10, 24, 10, 0));
        when(chantierRepository.findById(7L)).thenReturn(Optional.of(chantier));

        var erreur = assertThrows(com.eliteplaco.api.exception.ConflictException.class,
                () -> chantierService.changerStatut(
                        7L,
                        Chantier.StatutChantier.EN_PAUSE,
                        LocalDateTime.of(2026, 10, 24, 9, 59)));

        assertEquals("CONFLIT : Ce chantier a été modifié par un autre utilisateur depuis votre dernière synchronisation.",
                erreur.getMessage());
        verify(chantierRepository, never()).save(chantier);
    }

    private Chantier chantier(String nom, BigDecimal devis) {
        Chantier chantier = new Chantier();
        chantier.setNomClient(nom);
        chantier.setMontantDevis(devis);
        chantier.setLastModifiedDate(LocalDateTime.of(2026, 10, 24, 8, 0));
        return chantier;
    }
}
