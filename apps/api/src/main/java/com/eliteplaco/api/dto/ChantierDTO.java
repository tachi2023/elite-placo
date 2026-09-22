package com.eliteplaco.api.dto;

import java.math.BigDecimal;

/**
 * Vue "dirigeant" d'un chantier — inclut les données financières.
 * Ne JAMAIS renvoyer cet objet sur l'endpoint public de suivi client
 * (voir ChantierSuiviPublicDTO à la place, plus restreint).
 */
public record ChantierDTO(
        Long id,
        String nomClient,
        String ville,
        String typeTravaux,
        String statut,
        BigDecimal montantDevis,
        BigDecimal totalEncaisse,
        BigDecimal totalDepenses,
        BigDecimal resultatNet,
        BigDecimal margeBrutePourcent,
        String indicateur, // "VERT" | "ORANGE" | "ROUGE"
        java.time.LocalDateTime lastModifiedDate
) {}
