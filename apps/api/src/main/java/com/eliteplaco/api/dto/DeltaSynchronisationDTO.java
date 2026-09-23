package com.eliteplaco.api.dto;

import java.time.LocalDateTime;
import java.util.List;

public record DeltaSynchronisationDTO(
        LocalDateTime serveurDate,
        List<ChantierDTO> chantiers,
        List<MouvementSynchronisationDTO> mouvements,
        List<OuvrierSynchronisationDTO> ouvriers,
        List<AffectationOuvrierSynchronisationDTO> affectationsOuvriers,
        List<FicheMetrageSynchronisationDTO> fichesMetrage,
        List<PieceMetrageSynchronisationDTO> piecesMetrage
) {}
