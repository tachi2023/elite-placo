package com.eliteplaco.api.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.Map;

/**
 * Centralise les réponses d'erreur (évite de dupliquer des try/catch dans
 * chaque contrôleur). Complète la validation @Valid déjà en place sur les
 * DTO (ex. LoginRequest, MouvementFinancierDTO).
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, String>> gererValidation(MethodArgumentNotValidException ex) {
        Map<String, String> erreurs = new HashMap<>();
        ex.getBindingResult().getFieldErrors()
          .forEach(err -> erreurs.put(err.getField(), err.getDefaultMessage()));
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(erreurs);
    }

    @ExceptionHandler(AppException.class)
    public ResponseEntity<Map<String, String>> gererAppException(AppException ex) {
        Map<String, String> erreur = new HashMap<>();
        erreur.put("message", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(erreur);
    }

    // TODO (Phase 6) : ajouter un handler pour ChantierArchiveException
    // (§10.10, §10.13-A5 — blocage modification sur chantier archivé), etc.
}
