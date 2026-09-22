package com.eliteplaco.api.dto;

import java.math.BigDecimal;
import java.util.List;

public record ResultatMateriauxDTO(
        String systeme,
        double surfaceM2,
        List<QuantiteMateriauDTO> lignes,
        BigDecimal budgetTotal,   // null si au moins un prix unitaire manque
        boolean budgetIncomplet
) {}
