package com.example.autotrader.core.exceptions;

/**
 * Exception when a resource is not found
 */
public class ResourceNotFoundException extends BusinessException {
    
    public ResourceNotFoundException(String message) {
        super("NOT_FOUND", message, 404);
    }
    
    public ResourceNotFoundException(String resourceName, Long id) {
        super("NOT_FOUND", String.format("%s với ID %d không tồn tại", resourceName, id), 404);
    }
    
    public ResourceNotFoundException(String resourceName, Object id) {
        super("NOT_FOUND", String.format("%s với ID %s không tồn tại", resourceName, id.toString()), 404);
    }
}
