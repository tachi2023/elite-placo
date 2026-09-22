package com.eliteplaco.api.dto;

import java.math.BigDecimal;

public record QuantiteMateriauDTO(
        String nomMateriau,
        double quantite,
        String unite,
        BigDecimal prixUnitaire // null si non renseigné (§10.5-A4)
) {
    public BigDecimal sousTotal() {
        return prixUnitaire == null ? null : prixUnitaire.multiply(BigDecimal.valueOf(quantite));
    }
}
