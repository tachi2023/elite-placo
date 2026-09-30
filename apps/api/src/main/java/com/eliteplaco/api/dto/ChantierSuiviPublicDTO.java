package com.eliteplaco.api.dto;

import java.math.BigDecimal;

/**
 * Vue "client final" d'un chantier (Module 7).
 * Sans accès aux données financières internes.
 */
public record ChantierSuiviPublicDTO(
        String nomClient,
        String ville,
        String statut,
        int avancementPourcent,
        BigDecimal montantDevis,
        BigDecimal totalEncaisse,
        BigDecimal resteAPayer
) {}
