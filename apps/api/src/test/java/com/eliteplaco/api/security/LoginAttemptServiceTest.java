package com.eliteplaco.api.security;

import com.eliteplaco.api.exception.AppException;
import org.junit.jupiter.api.Test;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneOffset;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class LoginAttemptServiceTest {

    @Test
    void bloqueApresCinqEchecsEtRetourne429() {
        LoginAttemptService service = new LoginAttemptService(
                5, Duration.ofMinutes(15),
                Clock.fixed(Instant.parse("2026-09-23T00:00:00Z"), ZoneOffset.UTC));

        for (int i = 0; i < 5; i++) {
            service.enregistrerEchec(" Dirigeant ");
        }

        AppException exception = assertThrows(AppException.class,
                () -> service.verifierNonBloque("dirigeant"));
        assertEquals(429, exception.getStatus().value());
    }

    @Test
    void succesReinitialiseLeCompteur() {
        LoginAttemptService service = new LoginAttemptService(
                2, Duration.ofMinutes(15), Clock.systemUTC());
        service.enregistrerEchec("dirigeant");
        service.enregistrerSucces("DIRIGEANT");

        service.enregistrerEchec("dirigeant");
        assertDoesNotThrow(() -> service.verifierNonBloque("dirigeant"));
    }
}
