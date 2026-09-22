package com.eliteplaco.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;

public record PieceMetrageRequest(
        @NotBlank String nomPiece,
        @Positive BigDecimal longueur,
        @Positive BigDecimal largeur,
        BigDecimal surfaceDeduction
) {}
