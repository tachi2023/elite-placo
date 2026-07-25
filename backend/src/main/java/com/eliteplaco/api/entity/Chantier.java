package com.eliteplaco.api.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Chantier — entité centrale du modèle de domaine (Module 1 et 2).
 * Statuts possibles : A_VENIR, EN_COURS, EN_PAUSE, TERMINE, ARCHIVE
 * (cf. diagramme d'états-transitions déjà produit).
 */
@Entity
@Table(name = "chantier")
@Getter
@Setter
public class Chantier {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Column(nullable = false)
    private String nomClient;

    private String ville;

    private String typeTravaux;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatutChantier statut = StatutChantier.A_VENIR;

    @PositiveOrZero
    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal montantDevis = BigDecimal.ZERO;

    // Code d'accès transmis au client final pour l'espace client (Module 7 — hors MVP)
    private String codeAccesClient;

    @Column(nullable = false)
    private LocalDateTime dateCreation = LocalDateTime.now();

    @Column(nullable = false)
    private LocalDateTime lastModifiedDate = LocalDateTime.now();

    // Ajouté par le Script 2 (V2) : marquage hors-ligne (§"Marquage des données en attente")
    @Column(nullable = false)
    private Boolean synchronise = true;

    // Composition : un chantier possède ses propres mouvements financiers.
    // orphanRemoval = true car un Encaissement/Dépense n'existe pas sans son chantier.
    @OneToMany(mappedBy = "chantier", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<MouvementFinancier> mouvements = new ArrayList<>();

    // --- Calculs dérivés (attributs "/" du diagramme de classes) ---
    // La logique réelle sera implémentée dans ChantierService, pas ici :
    // l'entité JPA reste un simple porteur de données (pas de règle métier).

    public enum StatutChantier {
        A_VENIR, EN_COURS, EN_PAUSE, TERMINE, ARCHIVE
    }
}
