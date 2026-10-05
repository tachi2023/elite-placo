package com.eliteplaco.api.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.lang.NonNull;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/** Limite les routes publiques qui peuvent etre abusees ou couteuses. */
public class RateLimitingFilter extends OncePerRequestFilter {

    private final RateLimitService rateLimitService;

    public RateLimitingFilter(RateLimitService rateLimitService) {
        this.rateLimitService = rateLimitService;
    }

    @Override
    protected boolean shouldNotFilter(@NonNull HttpServletRequest request) {
        String uri = request.getRequestURI();
        boolean devis = ("POST".equalsIgnoreCase(request.getMethod())
                && ("/api/devis".equals(uri) || "/api/demandes-devis".equals(uri)));
        boolean suivi = uri.startsWith("/api/suivi/");
        return !("/api/auth/login".equals(uri) || "/api/auth/refresh".equals(uri)
                || "/api/avis".equals(uri) || devis || suivi);
    }

    @Override
    protected void doFilterInternal(@NonNull HttpServletRequest request,
                                    @NonNull HttpServletResponse response,
                                    @NonNull FilterChain filterChain)
            throws ServletException, IOException {
        String cle = request.getRemoteAddr() + ":" + request.getRequestURI();
        if (!rateLimitService.autoriser(cle)) {
            response.setStatus(429);
            response.setContentType("application/json");
            response.getWriter().write("{\"message\":\"Trop de requêtes. Réessayez plus tard.\"}");
            return;
        }
        filterChain.doFilter(request, response);
    }
}
