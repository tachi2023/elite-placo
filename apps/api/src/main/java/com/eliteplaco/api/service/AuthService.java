package com.eliteplaco.api.service;

import com.eliteplaco.api.dto.LoginRequest;
import com.eliteplaco.api.dto.LoginResponse;
import com.eliteplaco.api.entity.Utilisateur;
import com.eliteplaco.api.exception.AppException;
import com.eliteplaco.api.repository.UtilisateurRepository;
import com.eliteplaco.api.security.JwtService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import org.springframework.http.HttpStatus;

/**
 * Authentification du dirigeant (utilisateur unique, elite.md §4). Le
 * message d'erreur reste volontairement générique ("identifiants
 * incorrects") pour ne jamais révéler si c'est l'identifiant ou le mot de
 * passe qui est faux — règle de sécurité de base.
 */
@Service
public class AuthService {

    private final UtilisateurRepository utilisateurRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthService(UtilisateurRepository utilisateurRepository,
                        PasswordEncoder passwordEncoder,
                        JwtService jwtService) {
        this.utilisateurRepository = utilisateurRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    public LoginResponse login(LoginRequest requete) {
        Utilisateur utilisateur = utilisateurRepository.findByIdentifiant(requete.identifiant())
                .orElseThrow(() -> new AppException("Identifiants incorrects.", HttpStatus.UNAUTHORIZED));

        if (!passwordEncoder.matches(requete.motDePasse(), utilisateur.getMotDePasseHache())) {
            throw new AppException("Identifiants incorrects.", HttpStatus.UNAUTHORIZED);
        }

        String accessToken = jwtService.genererAccessToken(utilisateur.getIdentifiant());
        String refreshToken = jwtService.genererRefreshToken(utilisateur.getIdentifiant());

        return new LoginResponse(accessToken, refreshToken, jwtService.accessTokenExpirationSecondes());
    }

    public LoginResponse rafraichir(String refreshToken) {
        String identifiant = jwtService.extraireIdentifiant(refreshToken);
        if (identifiant == null) {
            throw new AppException("Jeton de rafraîchissement invalide ou expiré.", HttpStatus.UNAUTHORIZED);
        }
        // Vérifie que l'utilisateur existe toujours (compte non supprimé entre-temps).
        utilisateurRepository.findByIdentifiant(identifiant)
                .orElseThrow(() -> new AppException("Utilisateur introuvable.", HttpStatus.UNAUTHORIZED));

        String nouvelAccessToken = jwtService.genererAccessToken(identifiant);
        return new LoginResponse(nouvelAccessToken, refreshToken, jwtService.accessTokenExpirationSecondes());
    }
}
