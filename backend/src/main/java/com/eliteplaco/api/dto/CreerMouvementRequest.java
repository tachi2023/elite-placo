package com.eliteplaco.api.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;
import java.time.LocalDate;

public record CreerMouvementRequest(
        @NotNull @Positive BigDecimal montant,
        @NotNull LocalDate date,
        String nature,     // requis si encaissement
        String categorie,  // requis si dépense
        String description
) {}
