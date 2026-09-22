package com.eliteplaco.api.exception;

import org.springframework.http.HttpStatus;

/**
 * Exception métier levée par les services quand une règle du cahier des
 * charges n'est pas respectée. Le message est déjà rédigé en français et
 * prêt à être renvoyé tel quel au client (voir GlobalExceptionHandler).
 */
public class AppException extends RuntimeException {
    
    private HttpStatus status = HttpStatus.BAD_REQUEST;

    public AppException(String message) {
        super(message);
    }

    public AppException(String message, HttpStatus status) {
        super(message);
        this.status = status;
    }

    public HttpStatus getStatus() {
        return status;
    }
}
