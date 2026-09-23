package com.eliteplaco.api.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public record AffectationOuvrierSynchronisationDTO(
        Long id,
        Long ouvrierId,
        Long chantierId,
        BigDecimal montantPaye,
        LocalDate datePaiement,
        boolean synchronise,
        LocalDateTime lastModifiedDate
) {}
