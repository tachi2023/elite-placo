package com.eliteplaco.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.Map;

public record OperationSynchronisationDTO(
        @NotBlank String operationId,
        @NotBlank String entite,
        @NotBlank String action,
        Long localId,
        @NotNull Map<String, Object> donnees
) {}
