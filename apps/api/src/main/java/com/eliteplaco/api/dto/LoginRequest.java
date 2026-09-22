package com.eliteplaco.api.dto;

import jakarta.validation.constraints.NotBlank;

public record LoginRequest(
        @NotBlank String identifiant,
        @NotBlank String motDePasse
) {}
