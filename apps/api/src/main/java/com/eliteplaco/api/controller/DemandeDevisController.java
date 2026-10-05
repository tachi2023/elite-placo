package com.eliteplaco.api.controller;

import com.eliteplaco.api.dto.DemandeDevisDTO;
import com.eliteplaco.api.entity.DemandeDevis;
import com.eliteplaco.api.exception.AppException;
import com.eliteplaco.api.repository.DemandeDevisRepository;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping({"/api/devis", "/api/demandes-devis"})
public class DemandeDevisController {

    private final DemandeDevisRepository repository;

    public DemandeDevisController(DemandeDevisRepository repository) {
        this.repository = repository;
    }

    @GetMapping
    @PreAuthorize("isAuthenticated()")
    public List<DemandeDevisDTO> lister() {
        return repository.findAllByOrderByDateCreationDesc().stream()
                .map(DemandeDevisDTO::fromEntity)
                .toList();
    }

    @PostMapping
    public DemandeDevisDTO creer(@Valid @RequestBody DemandeDevisDTO demande) {
        if (demande.honeypot() != null && !demande.honeypot().isBlank()) {
            return new DemandeDevisDTO(null, "", null, "", null, "", null, null, null,
                    null, null, DemandeDevis.StatutDemande.NOUVELLE);
        }
        DemandeDevis entity = new DemandeDevis();
        entity.setNom(demande.nom());
        entity.setEmail(demande.email());
        entity.setTelephone(demande.telephone());
        entity.setVille(demande.ville());
        entity.setTypeTravaux(demande.typeTravaux());
        entity.setSuperficie(demande.superficie());
        entity.setBudgetEstime(demande.budgetEstime());
        entity.setMessage(demande.message());
        entity.setStatut(DemandeDevis.StatutDemande.NOUVELLE);
        return DemandeDevisDTO.fromEntity(repository.save(entity));
    }

    @PatchMapping("/{id}/statut")
    @PreAuthorize("isAuthenticated()")
    public DemandeDevisDTO changerStatut(@PathVariable Long id, @RequestParam DemandeDevis.StatutDemande statut) {
        DemandeDevis demande = repository.findById(id)
                .orElseThrow(() -> new AppException("Demande de devis introuvable."));
        demande.setStatut(statut);
        return DemandeDevisDTO.fromEntity(repository.save(demande));
    }
}
