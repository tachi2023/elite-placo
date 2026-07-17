package com.eliteplaco.api.dto;

import jakarta.validation.constraints.NotNull;

public record CreerFicheMetrageRequest(@NotNull String systeme) {}
