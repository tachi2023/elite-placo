package com.eliteplaco.api.entity;

import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;
import lombok.Getter;
import lombok.Setter;

/**
 * Encaissement reçu sur un chantier (acompte / versement / solde).
 */
@Entity
@DiscriminatorValue("ENCAISSEMENT")
@Getter
@Setter
public class Encaissement extends MouvementFinancier {

    // acompte / versement / solde (cf. cahier des charges Module 2)
    private String nature;
}
