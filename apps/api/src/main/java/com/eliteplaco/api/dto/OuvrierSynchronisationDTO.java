package com.eliteplaco.api.dto;

import java.time.LocalDateTime;

public record OuvrierSynchronisationDTO(
        Long id,
        String nomComplet,
        String telephone,
        Boolean synchronise,
        LocalDateTime lastModifiedDate
) {}
