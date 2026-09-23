package com.eliteplaco.api.dto;

import com.eliteplaco.api.entity.AvisClient;

import java.time.LocalDateTime;

public record AvisClientDTO(
        Long id,
        Long chantierId,
        String nomClient,
        int note,
        String commentaire,
        AvisClient.Statut statut,
        LocalDateTime dateCreation,
        LocalDateTime datePublication
) {
    public static AvisClientDTO fromEntity(AvisClient avis) {
        return new AvisClientDTO(avis.getId(), avis.getChantierId(), avis.getNomClient(), avis.getNote(),
                avis.getCommentaire(), avis.getStatut(), avis.getDateCreation(), avis.getDatePublication());
    }
}
