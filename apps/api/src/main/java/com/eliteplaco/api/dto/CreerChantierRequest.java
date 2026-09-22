package com.eliteplaco.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.PositiveOrZero;
import java.math.BigDecimal;

public record CreerChantierRequest(
        @NotBlank String nomClient,
        String ville,
        @NotBlank String typeTravaux,
        @PositiveOrZero BigDecimal montantDevis
) {}
