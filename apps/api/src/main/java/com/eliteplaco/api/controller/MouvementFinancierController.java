package com.eliteplaco.api.controller;

import com.eliteplaco.api.dto.CreerMouvementRequest;
import com.eliteplaco.api.dto.MouvementFinancierDTO;
import com.eliteplaco.api.entity.CategorieDepense;
import com.eliteplaco.api.entity.Depense;
import com.eliteplaco.api.entity.Encaissement;
import com.eliteplaco.api.entity.MouvementFinancier;
import com.eliteplaco.api.service.FinanceService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

/** Endpoints REST du Module 2 (encaissements et dépenses). */
@RestController
@RequestMapping("/api/chantiers/{chantierId}/mouvements")
public class MouvementFinancierController {

    private final FinanceService financeService;
    public MouvementFinancierController(FinanceService financeService) { this.financeService = financeService; }

    @GetMapping
    public List<MouvementFinancierDTO> lister(@PathVariable Long chantierId) {
        return financeService.listerParChantier(chantierId).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @PostMapping("/encaissements")
    public MouvementFinancierDTO ajouterEncaissement(@PathVariable Long chantierId,
                                                   @Valid @RequestBody CreerMouvementRequest requete) {
        return toDTO(financeService.enregistrerEncaissement(chantierId, requete.montant(), requete.date(), requete.nature()));
    }

    @PostMapping("/depenses")
    public MouvementFinancierDTO ajouterDepense(@PathVariable Long chantierId,
                                              @Valid @RequestBody CreerMouvementRequest requete) {
        CategorieDepense categorie = CategorieDepense.valueOf(requete.categorie());
        return toDTO(financeService.enregistrerDepense(chantierId, requete.montant(), requete.date(), categorie, requete.description()));
    }

    @PutMapping("/{mouvementId}")
    public MouvementFinancierDTO modifier(@PathVariable Long chantierId, @PathVariable Long mouvementId, @Valid @RequestBody CreerMouvementRequest requete) {
        return toDTO(financeService.modifier(chantierId, mouvementId, requete.montant(), requete.date()));
    }

    @DeleteMapping("/{mouvementId}")
    public void supprimer(@PathVariable Long chantierId, @PathVariable Long mouvementId) {
        financeService.supprimer(chantierId, mouvementId);
    }

    private MouvementFinancierDTO toDTO(MouvementFinancier m) {
        if (m instanceof Encaissement e) {
            return new MouvementFinancierDTO(m.getId(), "ENCAISSEMENT", m.getDate(), m.getMontant(), e.getNature(), null, null);
        } else if (m instanceof Depense d) {
            return new MouvementFinancierDTO(m.getId(), "DEPENSE", m.getDate(), m.getMontant(), null, d.getCategorie() != null ? d.getCategorie().name() : null, d.getDescription());
        }
        return null;
    }
}
