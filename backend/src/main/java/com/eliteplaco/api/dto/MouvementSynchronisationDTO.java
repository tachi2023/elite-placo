package com.eliteplaco.api.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public record MouvementSynchronisationDTO(
        Long id,
        Long chantierId,
        String typeMouvement,
        LocalDate date,
        BigDecimal montant,
        String nature,
        String categorie,
        String description,
        LocalDateTime lastModifiedDate
) {}
