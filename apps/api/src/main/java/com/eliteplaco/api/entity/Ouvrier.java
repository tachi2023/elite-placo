package com.eliteplaco.api.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

/**
 * Un ouvrier payé sur chantier (Module 6 — suivi des ouvriers).
 * Les paiements sont portés par AffectationOuvrier, pas ici : un même
 * ouvrier peut être affecté à plusieurs chantiers.
 */
@Entity
@Table(name = "ouvrier")
@Getter
@Setter
public class Ouvrier {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "nom_complet", nullable = false, length = 150)
    private String nomComplet;

    @Column(length = 30)
    private String telephone;
}
