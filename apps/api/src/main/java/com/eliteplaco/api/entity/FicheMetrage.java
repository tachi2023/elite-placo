package com.eliteplaco.api.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Fiche de métrage rattachée à un chantier (Module 5, elite.md §10.6).
 * La liste de pièces est bornée à 30 côté service (MetrageService), pas ici :
 * l'entité reste un simple porteur de données.
 */
@Entity
@Table(name = "fiche_metrage")
@Getter
@Setter
public class FicheMetrage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "chantier_id", nullable = false)
    private Chantier chantier;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SystemePlatrerie systeme;

    @Column(name = "date_creation", nullable = false)
    private LocalDateTime dateCreation = LocalDateTime.now();

    @Column(nullable = false)
    private Boolean synchronise = true;

    @OneToMany(mappedBy = "fiche", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<PieceMetrage> pieces = new ArrayList<>();

    public enum SystemePlatrerie {
        CORNIERE_FOURRURE_BA13, // plafond
        RAILS_MONTANTS_BA13     // cloison
    }
}
