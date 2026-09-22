package com.eliteplaco.api.dto;

import java.math.BigDecimal;

public record PieceMetrageDTO(
        Long id,
        String nomPiece,
        BigDecimal longueur,
        BigDecimal largeur,
        BigDecimal surfaceDeduction,
        Integer ordre
) {}
