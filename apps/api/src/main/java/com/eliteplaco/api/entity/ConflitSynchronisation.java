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

/** Conserve une operation obsolette au lieu de l'ecraser ou de la perdre. */
@Entity
@Table(name = "conflit_synchronisation")
@Getter
@Setter
public class ConflitSynchronisation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "operation_id", nullable = false, unique = true, length = 120)
    private String operationId;

    @Column(nullable = false, length = 60)
    private String entite;

    @Column(nullable = false, length = 60)
    private String action;

    private Long localId;

    @Column(name = "payload_json", nullable = false, columnDefinition = "TEXT")
    private String payloadJson;

    @Column(nullable = false, length = 500)
    private String message;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Statut statut = Statut.OUVERT;

    @Column(nullable = false)
    private LocalDateTime dateCreation = LocalDateTime.now();

    public enum Statut {
        OUVERT, RESOLU, IGNORE
    }
}
