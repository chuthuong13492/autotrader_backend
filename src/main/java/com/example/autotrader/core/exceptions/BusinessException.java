package com.example.autotrader.core.exceptions;

import lombok.Getter;

/**
 * Base exception for business logic errors
 */
@Getter
public class BusinessException extends RuntimeException {
    
    private final String errorCode;
    private final Integer statusCode;
    private final Object details;
    
    public BusinessException(String message) {
        super(message);
        this.errorCode = "BUSINESS_ERROR";
        this.statusCode = 400;
        this.details = null;
    }
    
    public BusinessException(String errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
        this.statusCode = 400;
        this.details = null;
    }
    
    public BusinessException(String errorCode, String message, Integer statusCode) {
        super(message);
        this.errorCode = errorCode;
        this.statusCode = statusCode;
        this.details = null;
    }
    
    public BusinessException(String errorCode, String message, Integer statusCode, Object details) {
        super(message);
        this.errorCode = errorCode;
        this.statusCode = statusCode;
        this.details = details;
    }
    
    public BusinessException(String errorCode, String message, Throwable cause) {
        super(message, cause);
        this.errorCode = errorCode;
        this.statusCode = 400;
        this.details = null;
    }
}
