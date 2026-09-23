package com.eliteplaco.api.security;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * Utilisateur unique (le dirigeant) : pas de multi-rôle, sécurité
 * proportionnée au risque réel (elite.md §4). L'endpoint public
 * /api/suivi/** reste accessible sans jeton (Module 7).
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final JwtService jwtService;
    private final RateLimitService rateLimitService;

    @Value("${spring.profiles.active:}")
    private String activeProfile;

    public SecurityConfig(JwtService jwtService, RateLimitService rateLimitService) {
        this.jwtService = jwtService;
        this.rateLimitService = rateLimitService;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        boolean localProfile = activeProfile != null && activeProfile.contains("local");
        http
            .csrf(csrf -> csrf.disable()) // API stateless consommée par le client Flutter
            .cors(org.springframework.security.config.Customizer.withDefaults())
            .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> {
                auth.requestMatchers("/", "/actuator/health", "/api/auth/**", "/api/suivi/**").permitAll()
                    .requestMatchers(org.springframework.http.HttpMethod.GET, "/api/contenu-site/**").permitAll();
                if (localProfile) {
                    auth.requestMatchers("/h2-console/**").permitAll();
                }
                auth.anyRequest().authenticated();
            })
            .headers(headers -> {
                if (localProfile) {
                    headers.frameOptions(frame -> frame.sameOrigin());
                }
            })
            .addFilterBefore(new RateLimitingFilter(rateLimitService), UsernamePasswordAuthenticationFilter.class)
            .addFilterBefore(new JwtAuthFilter(jwtService), UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
