package com.eliteplaco.api.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "demande_devis")
@Getter
@Setter
public class DemandeDevis {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Size(max = 120)
    @Column(nullable = false)
    private String nom;

    @Email
    @Size(max = 255)
    private String email;

    @NotBlank
    @Size(max = 50)
    @Column(nullable = false)
    private String telephone;

    @Size(max = 120)
    private String ville;

    @NotBlank
    @Size(max = 120)
    @Column(name = "type_travaux", nullable = false)
    private String typeTravaux;

    @Size(max = 50)
    private String superficie;

    @Size(max = 80)
    private String budgetEstime;

    @Size(max = 4000)
    @Column(columnDefinition = "TEXT")
    private String message;

    @Column(nullable = false)
    private LocalDateTime dateCreation = LocalDateTime.now();

    @Column(nullable = false, length = 30)
    @Enumerated(EnumType.STRING)
    private StatutDemande statut = StatutDemande.NOUVELLE;

    public enum StatutDemande {
        NOUVELLE, CONTACTEE, DEVIS_ENVOYE, GAGNEE, PERDUE
    }
}
