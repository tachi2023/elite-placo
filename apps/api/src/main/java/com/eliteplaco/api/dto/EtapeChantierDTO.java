package com.eliteplaco.api.dto;

import com.eliteplaco.api.entity.EtapeChantier;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.LocalDateTime;

public record EtapeChantierDTO(
        Long id,
        @NotBlank @Size(max = 120) String libelle,
        @NotNull Integer ordre,
        EtapeChantier.StatutEtape statut,
        LocalDateTime dateFin
) {
    public static EtapeChantierDTO fromEntity(EtapeChantier e) {
        return new EtapeChantierDTO(e.getId(), e.getLibelle(), e.getOrdre(), e.getStatut(), e.getDateFin());
    }
}
