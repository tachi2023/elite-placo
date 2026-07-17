package com.eliteplaco.api.entity;

import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.Getter;
import lombok.Setter;

/**
 * Dépense engagée sur un chantier, classée par catégorie.
 */
@Entity
@DiscriminatorValue("DEPENSE")
@Getter
@Setter
public class Depense extends MouvementFinancier {

    @Enumerated(EnumType.STRING)
    private CategorieDepense categorie;

    private String description;
}
