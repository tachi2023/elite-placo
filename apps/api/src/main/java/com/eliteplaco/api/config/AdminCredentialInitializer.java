package com.eliteplaco.api.config;

import com.eliteplaco.api.entity.Utilisateur;
import com.eliteplaco.api.repository.UtilisateurRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

/** Applique le secret ADMIN_PASSWORD Render sans jamais stocker le mot de passe en clair. */
@Configuration
public class AdminCredentialInitializer {

    @Bean
    ApplicationRunner initialiserMotDePasseAdmin(
            UtilisateurRepository repository,
            PasswordEncoder passwordEncoder,
            @Value("${app.admin.password:}") String motDePasse) {
        return args -> {
            if (motDePasse == null || motDePasse.isBlank()) {
                return;
            }
            Utilisateur utilisateur = repository.findByIdentifiant("raoul.michel").orElse(null);
            if (utilisateur != null && !passwordEncoder.matches(motDePasse, utilisateur.getMotDePasseHache())) {
                utilisateur.setMotDePasseHache(passwordEncoder.encode(motDePasse));
                repository.save(utilisateur);
            }
        };
    }
}
