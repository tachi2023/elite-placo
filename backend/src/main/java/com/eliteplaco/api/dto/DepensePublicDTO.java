package com.eliteplaco.api.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * DTO public pour rassurer le client final sur l'utilisation des fonds.
 */
public record DepensePublicDTO(
        String description,
        String categorie,
        BigDecimal montant,
        LocalDate date
) {}
