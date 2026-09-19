package com.eliteplaco.api.dto;

public record ResultatOperationSynchronisationDTO(
        String operationId,
        boolean succes,
        Long serveurId,
        String message
) {}
