package com.eliteplaco.api.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;
import java.time.LocalDate;

public record PaiementOuvrierRequest(
        @NotNull Long ouvrierId,
        @NotNull Long chantierId,
        @NotNull @Positive BigDecimal montant,
        @NotNull LocalDate date
) {}
