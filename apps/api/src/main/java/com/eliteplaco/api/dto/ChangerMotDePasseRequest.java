package com.eliteplaco.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ChangerMotDePasseRequest(
        @NotBlank @Size(max = 255) String ancienMotDePasse,
        @NotBlank @Size(min = 12, max = 255) String nouveauMotDePasse
) {}
