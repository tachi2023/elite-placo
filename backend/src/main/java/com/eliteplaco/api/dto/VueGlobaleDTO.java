package com.eliteplaco.api.dto;

import java.math.BigDecimal;
import java.util.List;

public record VueGlobaleDTO(
        BigDecimal chiffreAffairesTotal,
        BigDecimal totalEncaisseGlobal,
        BigDecimal totalDepensesGlobal,
        BigDecimal resultatNetGlobal,
        BigDecimal margeGlobalePourcent,
        List<ChantierDTO> resumesChantiers,
        boolean donneesPartiellementNonSynchronisees // §10.11-A2
) {}
