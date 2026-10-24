package com.eliteplaco.api.controller;

import com.eliteplaco.api.entity.Chantier;
import com.eliteplaco.api.entity.LienSuiviClient;
import com.eliteplaco.api.exception.AppException;
import com.eliteplaco.api.repository.DocumentChantierRepository;
import com.eliteplaco.api.repository.EtapeChantierRepository;
import com.eliteplaco.api.repository.LienSuiviClientRepository;
import com.eliteplaco.api.repository.PhotoChantierRepository;
import org.junit.jupiter.api.Test;
import org.springframework.core.env.Environment;

import java.time.LocalDateTime;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class SuiviClientExpirationTest {

    @Test
    void refuseUnLienExpire() {
        LienSuiviClientRepository liens = mock(LienSuiviClientRepository.class);
        EtapeChantierRepository etapes = mock(EtapeChantierRepository.class);
        PhotoChantierRepository photos = mock(PhotoChantierRepository.class);
        DocumentChantierRepository documents = mock(DocumentChantierRepository.class);
        Environment environment = mock(Environment.class);

        LienSuiviClient lien = new LienSuiviClient();
        lien.setCodePublic("EXPIRE-01");
        lien.setChantier(new Chantier());
        lien.setDateExpiration(LocalDateTime.now().minusMinutes(1));
        when(environment.getProperty("app.demo.enabled", "false")).thenReturn("false");
        when(liens.findByCodePublicAndActifTrue("EXPIRE-01")).thenReturn(Optional.of(lien));

        SuiviClientController controller = new SuiviClientController(
                liens, etapes, photos, documents, environment);

        AppException erreur = assertThrows(AppException.class,
                () -> controller.consulter("EXPIRE-01"));

        assertEquals("Ce lien de suivi a expiré.", erreur.getMessage());
    }
}
