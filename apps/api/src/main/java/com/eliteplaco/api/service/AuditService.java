package com.eliteplaco.api.service;

import com.eliteplaco.api.entity.Audit;
import com.eliteplaco.api.repository.AuditRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

/** Centralise l'ecriture des traces de securite et de conformite. */
@Service
public class AuditService {

    private final AuditRepository auditRepository;

    public AuditService(AuditRepository auditRepository) {
        this.auditRepository = auditRepository;
    }

    public Audit enregistrer(String action, String entite, Long entiteId,
                             Long chantierId, String details) {
        Audit audit = new Audit();
        audit.setDateHeure(LocalDateTime.now());
        audit.setUtilisateur(utilisateurCourant());
        audit.setAction(action);
        audit.setEntite(entite);
        audit.setEntiteId(entiteId);
        audit.setChantierId(chantierId);
        audit.setDetails(details);
        return auditRepository.save(audit);
    }

    private String utilisateurCourant() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || authentication.getName() == null || authentication.getName().isBlank()) {
            return "systeme";
        }
        return authentication.getName();
    }
}
