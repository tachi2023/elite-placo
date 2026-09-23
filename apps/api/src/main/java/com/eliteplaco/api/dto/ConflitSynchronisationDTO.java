package com.eliteplaco.api.dto;

import com.eliteplaco.api.entity.ConflitSynchronisation;

import java.time.LocalDateTime;

public record ConflitSynchronisationDTO(
        Long id,
        String operationId,
        String entite,
        String action,
        Long localId,
        String payloadJson,
        String message,
        ConflitSynchronisation.Statut statut,
        LocalDateTime dateCreation
) {
    public static ConflitSynchronisationDTO fromEntity(ConflitSynchronisation conflit) {
        return new ConflitSynchronisationDTO(conflit.getId(), conflit.getOperationId(), conflit.getEntite(),
                conflit.getAction(), conflit.getLocalId(), conflit.getPayloadJson(), conflit.getMessage(),
                conflit.getStatut(), conflit.getDateCreation());
    }
}
