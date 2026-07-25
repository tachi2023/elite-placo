package com.eliteplaco.api.dto;

import com.eliteplaco.api.entity.ContenuSite;

public record ContenuSiteDTO(
        Integer id,
        ContenuSite.TypeContenu type,
        String cle,
        String titre,
        String description,
        String imageUrl,
        Integer ordre
) {
    public static ContenuSiteDTO fromEntity(ContenuSite contenu) {
        return new ContenuSiteDTO(
                contenu.getId(),
                contenu.getType(),
                contenu.getCle(),
                contenu.getTitre(),
                contenu.getDescription(),
                contenu.getImageUrl(),
                contenu.getOrdre()
        );
    }
}
