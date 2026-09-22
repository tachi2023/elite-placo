package com.eliteplaco.api.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

public record AffectationOuvrierDTO(
        Long id,
        Long ouvrierId,
        String nomOuvrier,
        Long chantierId,
        BigDecimal montantPaye,
        LocalDate datePaiement
) {}
