package com.eliteplaco.api.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Positive;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

/** Une pièce dans une fiche de métrage (longueur/largeur en mètres). */
@Entity
@Table(name = "piece_metrage")
@Getter
@Setter
public class PieceMetrage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "fiche_metrage_id", nullable = false)
    private FicheMetrage fiche;

    @Column(name = "nom_piece", nullable = false)
    private String nomPiece;

    @Positive
    @Column(nullable = false, precision = 6, scale = 2)
    private BigDecimal longueur;

    @Positive
    @Column(nullable = false, precision = 6, scale = 2)
    private BigDecimal largeur;

    @Column(name = "surface_deduction", nullable = false, precision = 6, scale = 2)
    private BigDecimal surfaceDeduction = BigDecimal.ZERO;

    private Integer ordre = 1;

    // Calculs dérivés — volontairement absents ici (voir MetrageService),
    // l'entité JPA ne porte aucune règle métier (même principe que Chantier).
}
