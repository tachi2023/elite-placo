package com.eliteplaco.api.exception;

/**
 * Exception métier levée par les services quand une règle du cahier des
 * charges n'est pas respectée. Le message est déjà rédigé en français et
 * prêt à être renvoyé tel quel au client (voir GlobalExceptionHandler).
 */
public class AppException extends RuntimeException {
    public AppException(String message) {
        super(message);
    }
}
