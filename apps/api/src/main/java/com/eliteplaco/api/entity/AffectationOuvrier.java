package com.eliteplaco.api.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Paiement d'un ouvrier sur un chantier donné. Le total remonte
 * automatiquement dans les dépenses "main d'œuvre" du chantier
 * (voir OuvrierService.enregistrerPaiement — recalcul déclenché).
 */
@Entity
@Table(name = "affectation_ouvrier")
@Getter
@Setter
public class AffectationOuvrier {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "ouvrier_id")
    private Ouvrier ouvrier;

    @ManyToOne(optional = false)
    @JoinColumn(name = "chantier_id")
    private Chantier chantier;

    @Column(name = "montant_paye", nullable = false, precision = 12, scale = 2)
    private BigDecimal montantPaye;

    @Column(name = "date_paiement", nullable = false)
    private LocalDate datePaiement;

    @Column(nullable = false)
    private boolean synchronise = true;

    @Column(nullable = false)
    private LocalDateTime lastModifiedDate = LocalDateTime.now();
}
