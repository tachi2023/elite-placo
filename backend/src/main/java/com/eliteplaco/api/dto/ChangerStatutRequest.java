package com.eliteplaco.api.dto;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;

public record ChangerStatutRequest(
    @NotNull String nouveauStatut,
    LocalDateTime lastModifiedDate
) {}
