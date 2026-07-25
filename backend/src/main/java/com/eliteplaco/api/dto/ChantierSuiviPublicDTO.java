package com.eliteplaco.api.dto;

import java.util.List;

/**
 * Vue "client final" d'un chantier (Module 7).
 * Sans accès aux données financières internes.
 */
public record ChantierSuiviPublicDTO(
        String nomClient,
        String ville,
        String statut,
        int avancementPourcent
) {}
