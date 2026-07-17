package com.eliteplaco.api.controller;

import com.eliteplaco.api.dto.*;
import com.eliteplaco.api.entity.Chantier;
import com.eliteplaco.api.service.ChantierService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/** Endpoints REST du Module 1 (Gestion des chantiers) + calcul de situation (Module 2). */
@RestController
@RequestMapping("/api/chantiers")
public class ChantierController {

    private final ChantierService chantierService;
    public ChantierController(ChantierService chantierService) { this.chantierService = chantierService; }

    @GetMapping
    public List<ChantierDTO> lister() {
        return chantierService.listerActifs().stream().map(chantierService::calculerSituation).toList();
    }

    @GetMapping("/{id}")
    public ChantierDTO detail(@PathVariable Long id) {
        return chantierService.calculerSituation(chantierService.trouverParIdOuLever(id));
    }

    @PostMapping
    public ChantierDTO creer(@Valid @RequestBody CreerChantierRequest requete) {
        Chantier chantier = chantierService.creer(
                requete.nomClient(), requete.ville(), requete.typeTravaux(), requete.montantDevis());
        return chantierService.calculerSituation(chantier);
    }

    @PatchMapping("/{id}/statut")
    public ChantierDTO changerStatut(@PathVariable Long id, @Valid @RequestBody ChangerStatutRequest requete) {
        Chantier.StatutChantier nouveauStatut = Chantier.StatutChantier.valueOf(requete.nouveauStatut());
        Chantier chantier = chantierService.changerStatut(id, nouveauStatut);
        return chantierService.calculerSituation(chantier);
    }

    @PostMapping("/{id}/archiver")
    public ChantierDTO archiver(@PathVariable Long id) {
        return chantierService.calculerSituation(chantierService.archiver(id));
    }

    @PostMapping("/{id}/desarchiver")
    public ChantierDTO desarchiver(@PathVariable Long id) {
        return chantierService.calculerSituation(chantierService.desarchiver(id));
    }

    @PostMapping("/{id}/suivi")
    public String genererLienSuivi(@PathVariable Long id, @org.springframework.beans.factory.annotation.Autowired com.eliteplaco.api.service.LienSuiviClientService lienService) {
        Chantier chantier = chantierService.trouverParIdOuLever(id);
        return lienService.genererOuRecupererLien(chantier);
    }
}
