package com.eliteplaco.api.security;

import com.eliteplaco.api.exception.AppException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.Locale;
import java.util.concurrent.ConcurrentHashMap;

/** Protection en memoire contre les essais repetes sur un identifiant. */
@Service
public class LoginAttemptService {

    private final int maxFailures;
    private final Duration blockDuration;
    private final Clock clock;
    private final ConcurrentHashMap<String, AttemptState> states = new ConcurrentHashMap<>();

    @Autowired
    public LoginAttemptService(
            @Value("${app.security.brute-force.max-failures:5}") int maxFailures,
            @Value("${app.security.brute-force.block-minutes:15}") long blockMinutes) {
        this(maxFailures, Duration.ofMinutes(blockMinutes), Clock.systemUTC());
    }

    LoginAttemptService(int maxFailures, Duration blockDuration, Clock clock) {
        this.maxFailures = maxFailures;
        this.blockDuration = blockDuration;
        this.clock = clock;
    }

    public void verifierNonBloque(String identifiant) {
        String cle = normaliser(identifiant);
        AttemptState etat = states.get(cle);
        if (etat == null) {
            return;
        }
        Instant maintenant = clock.instant();
        if (etat.blockedUntil != null && maintenant.isBefore(etat.blockedUntil)) {
            throw new AppException("Trop de tentatives. Réessayez plus tard.", HttpStatus.TOO_MANY_REQUESTS);
        }
        if (etat.blockedUntil != null && !maintenant.isBefore(etat.blockedUntil)) {
            states.remove(cle, etat);
        }
    }

    public void enregistrerEchec(String identifiant) {
        String cle = normaliser(identifiant);
        states.compute(cle, (key, current) -> {
            AttemptState etat = current == null ? new AttemptState() : current;
            etat.failures++;
            if (etat.failures >= maxFailures) {
                etat.blockedUntil = clock.instant().plus(blockDuration);
            }
            return etat;
        });
    }

    public void enregistrerSucces(String identifiant) {
        states.remove(normaliser(identifiant));
    }

    private String normaliser(String identifiant) {
        return identifiant == null ? "" : identifiant.trim().toLowerCase(Locale.ROOT);
    }

    private static final class AttemptState {
        private int failures;
        private Instant blockedUntil;
    }
}
