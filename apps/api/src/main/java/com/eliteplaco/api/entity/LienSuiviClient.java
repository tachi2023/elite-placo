package com.eliteplaco.api.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;

/**
 * Lien public permettant au client final de suivre son chantier sans
 * compte (Module 7, §10.14/§10.15). Un seul lien actif à la fois par
 * chantier : voir LienSuiviClientService.regenerer().
 */
@Entity
@Table(name = "lien_suivi_client")
@Getter
@Setter
public class LienSuiviClient {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "chantier_id")
    private Chantier chantier;

    @Column(name = "code_public", nullable = false, unique = true, length = 20)
    private String codePublic;

    @Column(nullable = false)
    private boolean actif = true;

    @Column(name = "date_creation", nullable = false)
    private LocalDateTime dateCreation = LocalDateTime.now();

    @Column(name = "date_revocation")
    private LocalDateTime dateRevocation;

    @Column(name = "date_expiration")
    private LocalDateTime dateExpiration;
}
