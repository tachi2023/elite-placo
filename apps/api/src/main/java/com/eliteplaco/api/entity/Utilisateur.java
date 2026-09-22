package com.eliteplaco.api.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

/**
 * Compte du dirigeant (Raoul Michel). Un seul utilisateur interne pour le MVP
 * (multi-rôles repoussé en roadmap — voir Architecture_Technique_ElitePlaco.md).
 */
@Entity
@Table(name = "utilisateur")
@Getter
@Setter
public class Utilisateur {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String identifiant;

    // Mot de passe haché avec BCrypt — jamais stocké en clair (règle sécurité n°1)
    @Column(nullable = false)
    private String motDePasseHache;
}
