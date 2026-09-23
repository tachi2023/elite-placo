package com.eliteplaco.api.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record PieceMetrageSynchronisationDTO(
        Long id,
        Long ficheMetrageId,
        String nomPiece,
        BigDecimal longueur,
        BigDecimal largeur,
        BigDecimal surfaceDeduction,
        Integer ordre,
        Boolean synchronise,
        LocalDateTime lastModifiedDate
) {}
