package com.eliteplaco.api.controller;

import com.eliteplaco.api.dto.CreerMouvementRequest;
import com.eliteplaco.api.entity.CategorieDepense;
import com.eliteplaco.api.entity.MouvementFinancier;
import com.eliteplaco.api.service.FinanceService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/** Endpoints REST du Module 2 (encaissements et dépenses). */
@RestController
@RequestMapping("/api/chantiers/{chantierId}/mouvements")
public class MouvementFinancierController {

    private final FinanceService financeService;
    public MouvementFinancierController(FinanceService financeService) { this.financeService = financeService; }

    @GetMapping
    public List<MouvementFinancier> lister(@PathVariable Long chantierId) {
        return financeService.listerParChantier(chantierId);
    }

    @PostMapping("/encaissements")
    public MouvementFinancier ajouterEncaissement(@PathVariable Long chantierId,
                                                   @Valid @RequestBody CreerMouvementRequest requete) {
        return financeService.enregistrerEncaissement(chantierId, requete.montant(), requete.date(), requete.nature());
    }

    @PostMapping("/depenses")
    public MouvementFinancier ajouterDepense(@PathVariable Long chantierId,
                                              @Valid @RequestBody CreerMouvementRequest requete) {
        CategorieDepense categorie = CategorieDepense.valueOf(requete.categorie());
        return financeService.enregistrerDepense(chantierId, requete.montant(), requete.date(), categorie, requete.description());
    }

    @PutMapping("/{mouvementId}")
    public MouvementFinancier modifier(@PathVariable Long mouvementId, @Valid @RequestBody CreerMouvementRequest requete) {
        return financeService.modifier(mouvementId, requete.montant(), requete.date());
    }

    @DeleteMapping("/{mouvementId}")
    public void supprimer(@PathVariable Long mouvementId) {
        financeService.supprimer(mouvementId);
    }
}
