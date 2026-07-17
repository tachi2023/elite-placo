package com.eliteplaco.api.dto;

import jakarta.validation.constraints.NotNull;

public record ChangerStatutRequest(@NotNull String nouveauStatut) {}
