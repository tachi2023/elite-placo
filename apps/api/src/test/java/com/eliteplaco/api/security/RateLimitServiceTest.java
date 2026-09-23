package com.eliteplaco.api.security;

import org.junit.jupiter.api.Test;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneOffset;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class RateLimitServiceTest {

    @Test
    void limiteLesRequetesDansUneFenetre() {
        RateLimitService service = new RateLimitService(
                2, Duration.ofMinutes(1),
                Clock.fixed(Instant.parse("2026-09-23T00:00:00Z"), ZoneOffset.UTC));

        assertTrue(service.autoriser("127.0.0.1:/api/auth/login"));
        assertTrue(service.autoriser("127.0.0.1:/api/auth/login"));
        assertFalse(service.autoriser("127.0.0.1:/api/auth/login"));
        assertTrue(service.autoriser("127.0.0.1:/api/auth/refresh"));
    }
}
