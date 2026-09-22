package com.eliteplaco.api.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

/**
 * Génération et validation des jetons JWT (accès courte durée + rafraîchissement
 * longue durée) — voir elite.md §3 : JWT maison, pas de fournisseur OAuth2
 * externe, décision assumée pour un utilisateur unique (le dirigeant).
 */
@Service
public class JwtService {

    @Value("${app.jwt.secret}")
    private String secret;

    @Value("${app.jwt.access-token-expiration-ms}")
    private long accessTokenExpirationMs;

    @Value("${app.jwt.refresh-token-expiration-ms}")
    private long refreshTokenExpirationMs;

    private SecretKey cle() {
        // Le secret doit faire au moins 256 bits (32 caractères) — voir .env.example.
        return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }

    public String genererAccessToken(String identifiant) {
        return genererToken(identifiant, accessTokenExpirationMs, "access");
    }

    public String genererRefreshToken(String identifiant) {
        return genererToken(identifiant, refreshTokenExpirationMs, "refresh");
    }

    private String genererToken(String identifiant, long dureeMs, String type) {
        Date maintenant = new Date();
        Date expiration = new Date(maintenant.getTime() + dureeMs);
        return Jwts.builder()
                .subject(identifiant)
                .claim("typ", type)
                .issuedAt(maintenant)
                .expiration(expiration)
                .signWith(cle())
                .compact();
    }

    public boolean isAccessToken(String token) {
        try {
            Claims claims = Jwts.parser().verifyWith(cle()).build()
                    .parseSignedClaims(token).getPayload();
            return "access".equals(claims.get("typ"));
        } catch (Exception e) {
            return false;
        }
    }

    /** Renvoie l'identifiant contenu dans le jeton, ou null s'il est invalide/expiré. */
    public String extraireIdentifiant(String token) {
        try {
            Claims claims = Jwts.parser().verifyWith(cle()).build()
                    .parseSignedClaims(token).getPayload();
            return claims.getSubject();
        } catch (Exception e) {
            return null;
        }
    }

    public boolean estValide(String token) {
        try {
            Jwts.parser().verifyWith(cle()).build().parseSignedClaims(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public long accessTokenExpirationSecondes() {
        return accessTokenExpirationMs / 1000;
    }
}
