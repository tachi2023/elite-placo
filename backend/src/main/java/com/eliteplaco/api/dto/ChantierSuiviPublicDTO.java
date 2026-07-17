package com.eliteplaco.api.dto;

import java.util.List;

/**
 * Vue "client final" d'un chantier (Module 7).
 * Modifié suite à la demande du client pour inclure un aperçu des dépenses
 * effectuées afin de rassurer le client final sur l'avancement.
 */
public record ChantierSuiviPublicDTO(
        String nomClient,
        String ville,
        String statut,
        int avancementPourcent,
        List<DepensePublicDTO> depenses
) {}
