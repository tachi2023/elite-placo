package com.eliteplaco.api.service;

import com.eliteplaco.api.entity.Audit;
import com.eliteplaco.api.repository.AuditRepository;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class AuditServiceTest {

    @AfterEach
    void nettoyerContexteSecurite() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void enregistreUtilisateurActionEtContexte() {
        AuditRepository repository = mock(AuditRepository.class);
        when(repository.save(any(Audit.class))).thenAnswer(invocation -> invocation.getArgument(0));
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken("dirigeant", null));

        new AuditService(repository).enregistrer(
                "MODIFICATION", "MOUVEMENT_FINANCIER", 8L, 2L, "Test");

        ArgumentCaptor<Audit> captor = ArgumentCaptor.forClass(Audit.class);
        verify(repository).save(captor.capture());
        Audit audit = captor.getValue();
        assertEquals("dirigeant", audit.getUtilisateur());
        assertEquals("MODIFICATION", audit.getAction());
        assertEquals("MOUVEMENT_FINANCIER", audit.getEntite());
        assertEquals(8L, audit.getEntiteId());
        assertEquals(2L, audit.getChantierId());
    }
}
