package com.eliteplaco.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "synchronisation_operation")
@Getter
@Setter
@NoArgsConstructor
public class SynchronisationOperation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 120)
    private String operationId;

    @Column(nullable = false)
    private boolean succes;

    private Long serveurId;

    @Column(length = 500)
    private String message;

    public SynchronisationOperation(String operationId, boolean succes, Long serveurId, String message) {
        this.operationId = operationId;
        this.succes = succes;
        this.serveurId = serveurId;
        this.message = message;
    }
}
