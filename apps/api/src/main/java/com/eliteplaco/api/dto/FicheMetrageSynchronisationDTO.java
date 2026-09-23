package com.eliteplaco.api.dto;

import java.time.LocalDateTime;
import java.util.List;

public record FicheMetrageSynchronisationDTO(
        Long id,
        Long chantierId,
        String systeme,
        LocalDateTime dateCreation,
        Boolean synchronise,
        LocalDateTime lastModifiedDate,
        List<PieceMetrageSynchronisationDTO> pieces
) {}
