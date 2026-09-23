package com.eliteplaco.api.security;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.concurrent.ConcurrentHashMap;

/** Limiteur simple par instance pour les endpoints d'authentification. */
@Service
public class RateLimitService {

    private final int maxRequests;
    private final Duration window;
    private final Clock clock;
    private final ConcurrentHashMap<String, WindowState> states = new ConcurrentHashMap<>();

    public RateLimitService(
            @Value("${app.security.rate-limit.auth.max-requests:10}") int maxRequests,
            @Value("${app.security.rate-limit.auth.window-seconds:60}") long windowSeconds) {
        this(maxRequests, Duration.ofSeconds(windowSeconds), Clock.systemUTC());
    }

    RateLimitService(int maxRequests, Duration window, Clock clock) {
        this.maxRequests = maxRequests;
        this.window = window;
        this.clock = clock;
    }

    public boolean autoriser(String cle) {
        Instant maintenant = clock.instant();
        WindowState etat = states.compute(cle, (key, current) -> {
            if (current == null || !maintenant.isBefore(current.debut.plus(window))) {
                return new WindowState(maintenant, 1);
            }
            current.compteur++;
            return current;
        });
        return etat.compteur <= maxRequests;
    }

    private static final class WindowState {
        private final Instant debut;
        private int compteur;

        private WindowState(Instant debut, int compteur) {
            this.debut = debut;
            this.compteur = compteur;
        }
    }
}
