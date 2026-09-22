package com.eliteplaco.api.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;
import java.util.Map;

public record CalculMateriauxRequest(
        @Positive double surfaceM2,
        @NotNull String systeme,
        Double perimetreM,
        Map<String, BigDecimal> prixUnitaires
) {}
