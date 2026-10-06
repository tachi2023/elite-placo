package com.eliteplaco.api.dto;

import com.eliteplaco.api.entity.EtapeChantier;
import java.time.LocalDateTime;

public record SuiviEtapeDTO(String libelle, int ordre, EtapeChantier.StatutEtape statut, LocalDateTime dateFin) {}
