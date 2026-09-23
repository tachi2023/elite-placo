package com.eliteplaco.api.dto;

import com.eliteplaco.api.entity.AvisClient;
import jakarta.validation.constraints.NotNull;

public record ModerationAvisRequest(@NotNull AvisClient.Statut statut) {}
