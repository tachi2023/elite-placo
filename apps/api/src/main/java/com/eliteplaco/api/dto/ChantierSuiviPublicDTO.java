package com.eliteplaco.api.dto;

import java.util.List;

/**
 * Vue publique d'un chantier (Module 7).
 * Aucune donnée financière n'est exposée au client final.
 */
public record ChantierSuiviPublicDTO(
        String nomClient,
        String ville,
        String statut,
        int avancementPourcent,
        List<SuiviEtapeDTO> etapes,
        List<SuiviMediaDTO> photos,
        List<SuiviMediaDTO> documents
) {}
