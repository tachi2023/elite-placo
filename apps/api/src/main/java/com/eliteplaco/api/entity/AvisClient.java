package com.eliteplaco.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

/** Commentaire client soumis a moderation avant affichage public. */
@Entity
@Table(name = "avis_client")
@Getter
@Setter
public class AvisClient {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "chantier_id", nullable = false)
    private Long chantierId;

    @Column(name = "nom_client", nullable = false, length = 120)
    private String nomClient;

    @Column(nullable = false)
    private int note;

    @Column(nullable = false, length = 1200)
    private String commentaire;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Statut statut = Statut.EN_ATTENTE;

    @Column(name = "date_creation", nullable = false)
    private LocalDateTime dateCreation = LocalDateTime.now();

    @Column(name = "date_publication")
    private LocalDateTime datePublication;

    public enum Statut {
        EN_ATTENTE, APPROUVE, REJETE
    }
}
