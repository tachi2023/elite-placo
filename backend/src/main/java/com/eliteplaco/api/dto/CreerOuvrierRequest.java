package com.eliteplaco.api.dto;

import jakarta.validation.constraints.NotBlank;

public record CreerOuvrierRequest(@NotBlank String nomComplet, String telephone) {}
