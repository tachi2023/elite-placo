package com.eliteplaco.api.dto;

import java.time.LocalDateTime;
import java.util.List;

public record FicheMetrageDTO(
        Long id,
        Long chantierId,
        String systeme,
        LocalDateTime dateCreation,
        List<PieceMetrageDTO> pieces
) {}
