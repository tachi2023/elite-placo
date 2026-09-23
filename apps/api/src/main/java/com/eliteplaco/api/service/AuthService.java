package com.eliteplaco.api.service;

import com.eliteplaco.api.dto.LoginRequest;
import com.eliteplaco.api.dto.LoginResponse;
import com.eliteplaco.api.entity.Utilisateur;
import com.eliteplaco.api.exception.AppException;
import com.eliteplaco.api.repository.UtilisateurRepository;
import com.eliteplaco.api.security.JwtService;
import com.eliteplaco.api.security.LoginAttemptService;
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
    private final LoginAttemptService loginAttemptService;

    public AuthService(UtilisateurRepository utilisateurRepository,
                        PasswordEncoder passwordEncoder,
                        JwtService jwtService,
                        LoginAttemptService loginAttemptService) {
        this.utilisateurRepository = utilisateurRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.loginAttemptService = loginAttemptService;
    }

    public LoginResponse login(LoginRequest requete) {
        String identifiant = requete.identifiant();
        loginAttemptService.verifierNonBloque(identifiant);
        Utilisateur utilisateur = utilisateurRepository.findByIdentifiant(identifiant).orElse(null);

        if (utilisateur == null || !passwordEncoder.matches(requete.motDePasse(), utilisateur.getMotDePasseHache())) {
            loginAttemptService.enregistrerEchec(identifiant);
            throw new AppException("Identifiants incorrects.", HttpStatus.UNAUTHORIZED);
        }

        loginAttemptService.enregistrerSucces(identifiant);

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
