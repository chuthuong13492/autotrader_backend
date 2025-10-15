package com.example.autotrader.core.exceptions;

/**
 * Exception for validation errors
 */
public class ValidationException extends BusinessException {
    
    public ValidationException(String message) {
        super("VALIDATION_ERROR", message, 400);
    }
    
    public ValidationException(String message, Object details) {
        super("VALIDATION_ERROR", message, 400, details);
    }
}
