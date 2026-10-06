package com.eliteplaco.api.dto;

import java.time.LocalDateTime;

public record MediaChantierDTO(
        Long id,
        String url,
        String publicId,
        String libelle,
        String avantApres,
        boolean visibleClient,
        LocalDateTime dateCreation
) {}
