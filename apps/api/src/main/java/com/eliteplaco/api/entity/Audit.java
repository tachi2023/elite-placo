package com.eliteplaco.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

/** Trace immuable des actions sensibles du dirigeant et du systeme. */
@Entity
@Table(name = "audit")
@Getter
@Setter
public class Audit {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private LocalDateTime dateHeure = LocalDateTime.now();

    @Column(nullable = false, length = 120)
    private String utilisateur;

    @Column(nullable = false, length = 80)
    private String action;

    @Column(nullable = false, length = 80)
    private String entite;

    private Long entiteId;

    private Long chantierId;

    @Column(length = 2000)
    private String details;
}
