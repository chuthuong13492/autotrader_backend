package com.example.autotrader.core.data;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Represents a failure/error in the application
 * Similar to Flutter's Failure pattern
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Failure {
    
    /**
     * Error code for internationalization or specific error handling
     */
    private String errorCode;
    
    /**
     * Human-readable error message
     */
    private String message;
    
    /**
     * HTTP status code (if applicable)
     */
    private Integer statusCode;
    
    /**
     * Original exception (for debugging)
     */
    private Throwable cause;
    
    /**
     * Additional error details
     */
    private Object details;
    
    // Convenience constructors
    public Failure(String message) {
        this.message = message;
    }
    
    public Failure(String errorCode, String message) {
        this.errorCode = errorCode;
        this.message = message;
    }
    
    public Failure(String errorCode, String message, Integer statusCode) {
        this.errorCode = errorCode;
        this.message = message;
        this.statusCode = statusCode;
    }
    
    // Common failure factory methods
    public static Failure network(String message) {
        return Failure.builder()
                .errorCode("NETWORK_ERROR")
                .message(message != null ? message : "Network connection error. Please try again later.")
                .statusCode(503)
                .build();
    }
    
    public static Failure server(String message) {
        return Failure.builder()
                .errorCode("SERVER_ERROR")
                .message(message != null ? message : "Server error. Please try again later.")
                .statusCode(500)
                .build();
    }
    
    public static Failure validation(String message) {
        return Failure.builder()
                .errorCode("VALIDATION_ERROR")
                .message(message != null ? message : "Validation error. Please check your input.")
                .statusCode(400)
                .build();
    }
    
    public static Failure validation(String errorCode, String message) {
        return Failure.builder()
                .errorCode(errorCode)
                .message(message != null ? message : "Validation error. Please check your input.")
                .statusCode(400)
                .build();
    }
    
    public static Failure business(String errorCode, String message) {
        return Failure.builder()
                .errorCode(errorCode)
                .message(message != null ? message : "Business logic error.")
                .statusCode(400)
                .build();
    }
    
    public static Failure notFound(String message) {
        return Failure.builder()
                .errorCode("NOT_FOUND")
                .message(message != null ? message : "Resource not found.")
                .statusCode(404)
                .build();
    }
    
    public static Failure unauthorized(String message) {
        return Failure.builder()
                .errorCode("UNAUTHORIZED")
                .message(message != null ? message : "Unauthorized access.")
                .statusCode(401)
                .build();
    }
    
    public static Failure forbidden(String message) {
        return Failure.builder()
                .errorCode("FORBIDDEN")
                .message(message != null ? message : "Access forbidden.")
                .statusCode(403)
                .build();
    }
    
    public static Failure timeout(String message) {
        return Failure.builder()
                .errorCode("TIMEOUT")
                .message(message != null ? message : "Request timeout. Please try again.")
                .statusCode(408)
                .build();
    }
    
    public static Failure custom(String errorCode, String message, Integer statusCode) {
        return Failure.builder()
                .errorCode(errorCode)
                .message(message)
                .statusCode(statusCode)
                .build();
    }
}
