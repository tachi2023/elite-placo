package com.eliteplaco.api.service;

import com.eliteplaco.api.dto.ChantierDTO;
import com.eliteplaco.api.dto.VueGlobaleDTO;
import com.eliteplaco.api.entity.Chantier;
import com.eliteplaco.api.repository.ChantierRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

import org.springframework.transaction.annotation.Transactional;
import com.eliteplaco.api.repository.MouvementFinancierRepository;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Module 4 — agrège la situation de tous les chantiers : CA total,
 * encaissé/dépenses global, résultat net, marge globale, résumé par
 * chantier (elite.md §10.11). §10.11-A2 : les données locales font foi
 * même partiellement synchronisées — signalé, jamais bloquant.
 */
@Service
public class TableauDeBordService {

    private final ChantierRepository chantierRepository;
    private final ChantierService chantierService;
    private final MouvementFinancierRepository mouvementRepository;

    public TableauDeBordService(ChantierRepository chantierRepository, ChantierService chantierService, MouvementFinancierRepository mouvementRepository) {
        this.chantierRepository = chantierRepository;
        this.chantierService = chantierService;
        this.mouvementRepository = mouvementRepository;
    }

    /** §10.11-A1 — aucun chantier créé : vue vide, pas d'erreur. */
    @Transactional(readOnly = true)
    public VueGlobaleDTO calculerVueGlobale() {
        List<Chantier> chantiers = chantierRepository.findAll();

        if (chantiers.isEmpty()) {
            return new VueGlobaleDTO(BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO,
                    BigDecimal.ZERO, BigDecimal.ZERO, List.of(), false);
        }

        Map<Long, BigDecimal> encaissements = mouvementRepository.sommeEncaissementsParChantier().stream()
                .collect(Collectors.toMap(
                        row -> (Long) row[0],
                        row -> (BigDecimal) row[1]
                ));

        Map<Long, BigDecimal> depenses = mouvementRepository.sommeDepensesParChantier().stream()
                .collect(Collectors.toMap(
                        row -> (Long) row[0],
                        row -> (BigDecimal) row[1]
                ));

        BigDecimal ca = BigDecimal.ZERO, encaisseGlobal = BigDecimal.ZERO, depensesGlobal = BigDecimal.ZERO;
        boolean nonSync = false;
        List<ChantierDTO> resumes = new java.util.ArrayList<>();

        for (Chantier chantier : chantiers) {
            BigDecimal totalEncaisse = encaissements.getOrDefault(chantier.getId(), BigDecimal.ZERO);
            BigDecimal totalDepenses = depenses.getOrDefault(chantier.getId(), BigDecimal.ZERO);
            
            ChantierDTO situation = chantierService.calculerSituation(chantier, totalEncaisse, totalDepenses);
            ca = ca.add(chantier.getMontantDevis());
            encaisseGlobal = encaisseGlobal.add(situation.totalEncaisse());
            depensesGlobal = depensesGlobal.add(situation.totalDepenses());
            if (Boolean.FALSE.equals(chantier.getSynchronise())) nonSync = true;
            resumes.add(situation);
        }

        BigDecimal resultatNet = encaisseGlobal.subtract(depensesGlobal);
        BigDecimal margeGlobale = encaisseGlobal.compareTo(BigDecimal.ZERO) > 0
                ? resultatNet.divide(encaisseGlobal, 4, RoundingMode.HALF_UP).multiply(BigDecimal.valueOf(100))
                : BigDecimal.ZERO;

        return new VueGlobaleDTO(ca, encaisseGlobal, depensesGlobal, resultatNet, margeGlobale, resumes, nonSync);
    }
}
