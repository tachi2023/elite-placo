package com.eliteplaco.api.dto;

import com.eliteplaco.api.entity.DemandeDevis;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;

public record DemandeDevisDTO(
        Long id,
        @NotBlank @Size(max = 120) String nom,
        @Email @Size(max = 255) String email,
        @NotBlank @Size(max = 50) String telephone,
        @Size(max = 120) String ville,
        @NotBlank @Size(max = 120) String typeTravaux,
        @Size(max = 50) String superficie,
        @Size(max = 80) String budgetEstime,
        @Size(max = 4000) String message,
        @Size(max = 80) String honeypot,
        LocalDateTime dateCreation,
        DemandeDevis.StatutDemande statut
) {
    public static DemandeDevisDTO fromEntity(DemandeDevis demande) {
        return new DemandeDevisDTO(
                demande.getId(),
                demande.getNom(),
                demande.getEmail(),
                demande.getTelephone(),
                demande.getVille(),
                demande.getTypeTravaux(),
                demande.getSuperficie(),
                demande.getBudgetEstime(),
                demande.getMessage(),
                null,
                demande.getDateCreation(),
                demande.getStatut()
        );
    }
}
