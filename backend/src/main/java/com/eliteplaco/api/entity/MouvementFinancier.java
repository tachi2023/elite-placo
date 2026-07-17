package com.eliteplaco.api.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Positive;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Classe mère abstraite d'Encaissement et de Dépense.
 * Stratégie d'héritage SINGLE_TABLE : une seule table "mouvement_financier"
 * avec une colonne discriminante "type" — la plus simple et la plus rapide
 * à mettre en place pour un MVP solo (cf. Architecture_Technique_ElitePlaco.md §4).
 */
@Entity
@Table(name = "mouvement_financier")
@Inheritance(strategy = InheritanceType.SINGLE_TABLE)
@DiscriminatorColumn(name = "type_mouvement", discriminatorType = DiscriminatorType.STRING)
@Getter
@Setter
public abstract class MouvementFinancier {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private LocalDate date;

    @Positive
    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal montant;

    @ManyToOne(optional = false)
    @JoinColumn(name = "chantier_id", nullable = false)
    private Chantier chantier;

    // Ajouté par le Script 2 (V2) : marquage hors-ligne
    @Column(nullable = false)
    private Boolean synchronise = true;
}
