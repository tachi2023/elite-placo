package com.eliteplaco.api.dto;

import com.eliteplaco.api.entity.ConflitSynchronisation;
import jakarta.validation.constraints.NotNull;

public record ModifierConflitRequest(@NotNull ConflitSynchronisation.Statut statut) {}
