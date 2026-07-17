package com.eliteplaco.api.controller;

import com.eliteplaco.api.dto.CreerOuvrierRequest;
import com.eliteplaco.api.dto.PaiementOuvrierRequest;
import com.eliteplaco.api.entity.AffectationOuvrier;
import com.eliteplaco.api.entity.Ouvrier;
import com.eliteplaco.api.service.OuvrierService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/** Endpoints REST du Module 6 (suivi des ouvriers). */
@RestController
@RequestMapping("/api/ouvriers")
public class OuvrierController {

    private final OuvrierService ouvrierService;
    public OuvrierController(OuvrierService ouvrierService) { this.ouvrierService = ouvrierService; }

    @GetMapping
    public List<Ouvrier> lister() {
        return ouvrierService.lister();
    }

    @PostMapping
    public Ouvrier creer(@Valid @RequestBody CreerOuvrierRequest requete) {
        return ouvrierService.creer(requete.nomComplet(), requete.telephone());
    }

    @PostMapping("/paiements")
    public AffectationOuvrier payer(@Valid @RequestBody PaiementOuvrierRequest requete) {
        return ouvrierService.enregistrerPaiement(
                requete.ouvrierId(), requete.chantierId(), requete.montant(), requete.date());
    }
}
