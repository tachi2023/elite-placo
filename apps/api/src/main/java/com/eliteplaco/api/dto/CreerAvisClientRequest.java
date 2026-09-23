package com.eliteplaco.api.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreerAvisClientRequest(
        @NotBlank String codePublic,
        @NotBlank @Size(max = 120) String nomClient,
        @Min(1) @Max(5) int note,
        @NotBlank @Size(max = 1200) String commentaire
) {}
