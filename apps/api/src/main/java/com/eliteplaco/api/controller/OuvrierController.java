package com.eliteplaco.api.controller;

import com.eliteplaco.api.dto.CreerOuvrierRequest;
import com.eliteplaco.api.dto.OuvrierDTO;
import com.eliteplaco.api.dto.AffectationOuvrierDTO;
import com.eliteplaco.api.dto.PaiementOuvrierRequest;
import com.eliteplaco.api.entity.AffectationOuvrier;
import com.eliteplaco.api.entity.Ouvrier;
import com.eliteplaco.api.service.OuvrierService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

/** Endpoints REST du Module 6 (suivi des ouvriers). */
@RestController
@RequestMapping("/api/ouvriers")
public class OuvrierController {

    private final OuvrierService ouvrierService;
    public OuvrierController(OuvrierService ouvrierService) { this.ouvrierService = ouvrierService; }

    @GetMapping
    public List<OuvrierDTO> lister() {
        return ouvrierService.lister().stream()
                .map(this::toOuvrierDTO)
                .collect(Collectors.toList());
    }

    @PostMapping
    public OuvrierDTO creer(@Valid @RequestBody CreerOuvrierRequest requete) {
        return toOuvrierDTO(ouvrierService.creer(requete.nomComplet(), requete.telephone()));
    }

    @PostMapping("/paiements")
    public AffectationOuvrierDTO payer(@Valid @RequestBody PaiementOuvrierRequest requete) {
        return toAffectationDTO(ouvrierService.enregistrerPaiement(
                requete.ouvrierId(), requete.chantierId(), requete.montant(), requete.date()));
    }

    private OuvrierDTO toOuvrierDTO(Ouvrier ouvrier) {
        return new OuvrierDTO(ouvrier.getId(), ouvrier.getNomComplet(), ouvrier.getTelephone());
    }

    private AffectationOuvrierDTO toAffectationDTO(AffectationOuvrier aff) {
        return new AffectationOuvrierDTO(
                aff.getId(),
                aff.getOuvrier().getId(),
                aff.getOuvrier().getNomComplet(),
                aff.getChantier().getId(),
                aff.getMontantPaye(),
                aff.getDatePaiement()
        );
    }
}
