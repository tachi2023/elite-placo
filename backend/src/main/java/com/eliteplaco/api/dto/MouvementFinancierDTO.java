package com.eliteplaco.api.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;
import java.time.LocalDate;

public record MouvementFinancierDTO(
        Long id,
        @NotNull String typeMouvement,   // ENCAISSEMENT | DEPENSE
        @NotNull LocalDate date,
        @NotNull @Positive BigDecimal montant,
        String nature,        // renseigné si ENCAISSEMENT
        String categorie,     // renseigné si DEPENSE
        String description
) {}
