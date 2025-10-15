package com.example.autotrader.core.exceptions;

/**
 * Exception for network-related errors
 */
public class NetworkException extends BusinessException {
    
    public NetworkException(String message) {
        super("NETWORK_ERROR", message, 503);
    }
    
    public NetworkException(String message, Throwable cause) {
        super("NETWORK_ERROR", message, cause);
    }
}
