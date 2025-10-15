package com.example.autotrader.presentation.controllers;

import com.example.autotrader.core.exceptions.BusinessException;
import com.example.autotrader.core.exceptions.NetworkException;
import com.example.autotrader.core.exceptions.ResourceNotFoundException;
import com.example.autotrader.core.exceptions.ValidationException;
import com.example.autotrader.presentation.dtos.ApiResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.client.ResourceAccessException;

import java.net.SocketException;
import java.net.SocketTimeoutException;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeoutException;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {
    
    /**
     * Xử lý lỗi validation từ @Valid
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<Map<String, String>>> handleValidationExceptions(
            MethodArgumentNotValidException ex) {
        
        log.warn("Validation error: {}", ex.getMessage());
        
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach((error) -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            errors.put(fieldName, errorMessage);
        });
        
        return ResponseEntity.badRequest()
                .body(ApiResponse.<Map<String, String>>builder()
                        .success(false)
                        .message("Invalid input data")
                        .data(errors)
                        .timestamp(java.time.LocalDateTime.now().toString())
                        .build());
    }
    
    /**
     * Xử lý ResourceNotFoundException
     */
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ApiResponse<Object>> handleResourceNotFoundException(
            ResourceNotFoundException ex) {
        
        log.warn("Resource not found: {}", ex.getMessage());
        
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.<Object>builder()
                        .success(false)
                        .message(ex.getMessage())
                        .data(null)
                        .timestamp(java.time.LocalDateTime.now().toString())
                        .build());
    }
    
    /**
     * Xử lý ValidationException
     */
    @ExceptionHandler(ValidationException.class)
    public ResponseEntity<ApiResponse<Object>> handleValidationException(
            ValidationException ex) {
        
        log.warn("Validation exception: {}", ex.getMessage());
        
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.<Object>builder()
                        .success(false)
                        .message(ex.getMessage())
                        .data(ex.getDetails())
                        .timestamp(java.time.LocalDateTime.now().toString())
                        .build());
    }
    
    /**
     * Xử lý NetworkException
     */
    @ExceptionHandler(NetworkException.class)
    public ResponseEntity<ApiResponse<Object>> handleNetworkException(
            NetworkException ex) {
        
        log.error("Network exception: {}", ex.getMessage());
        
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                .body(ApiResponse.<Object>builder()
                        .success(false)
                        .message(ex.getMessage())
                        .data(null)
                        .timestamp(java.time.LocalDateTime.now().toString())
                        .build());
    }
    
    /**
     * Xử lý BusinessException
     */
    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ApiResponse<Object>> handleBusinessException(
            BusinessException ex) {
        
        log.warn("Business exception [{}]: {}", ex.getErrorCode(), ex.getMessage());
        
        HttpStatus status = HttpStatus.valueOf(ex.getStatusCode());
        
        return ResponseEntity.status(status)
                .body(ApiResponse.<Object>builder()
                        .success(false)
                        .message(ex.getMessage())
                        .data(ex.getDetails())
                        .timestamp(java.time.LocalDateTime.now().toString())
                        .build());
    }
    
    /**
     * Xử lý SocketTimeoutException
     */
    @ExceptionHandler(SocketTimeoutException.class)
    public ResponseEntity<ApiResponse<Object>> handleSocketTimeoutException(
            SocketTimeoutException ex) {
        
        log.error("Socket timeout: {}", ex.getMessage());
        
        return ResponseEntity.status(HttpStatus.REQUEST_TIMEOUT)
                .body(ApiResponse.error("Connection to the system took too long. Please try again later."));
    }
    
    /**
     * Xử lý TimeoutException
     */
    @ExceptionHandler(TimeoutException.class)
    public ResponseEntity<ApiResponse<Object>> handleTimeoutException(
            TimeoutException ex) {
        
        log.error("Timeout: {}", ex.getMessage());
        
        return ResponseEntity.status(HttpStatus.REQUEST_TIMEOUT)
                .body(ApiResponse.error("Request took too long. Please try again later."));
    }
    
    /**
     * Xử lý SocketException
     */
    @ExceptionHandler(SocketException.class)
    public ResponseEntity<ApiResponse<Object>> handleSocketException(
            SocketException ex) {
        
        log.error("Socket exception: {}", ex.getMessage());
        
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                .body(ApiResponse.error("Network connection lost. Please try again later."));
    }
    
    /**
     * Xử lý ResourceAccessException (Spring WebClient/RestTemplate)
     */
    @ExceptionHandler(ResourceAccessException.class)
    public ResponseEntity<ApiResponse<Object>> handleResourceAccessException(
            ResourceAccessException ex) {
        
        log.error("Resource access exception: {}", ex.getMessage());
        
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                .body(ApiResponse.error("Network connection error. Please try again later."));
    }
    
    /**
     * Xử lý HttpServerErrorException
     */
    @ExceptionHandler(HttpServerErrorException.class)
    public ResponseEntity<ApiResponse<Object>> handleHttpServerErrorException(
            HttpServerErrorException ex) {
        
        log.error("HTTP server error: {} - {}", ex.getStatusCode(), ex.getMessage());
        
        return ResponseEntity.status(ex.getStatusCode())
                .body(ApiResponse.error("The system is experiencing issues. Please try again later."));
    }
    
    /**
     * Xử lý HttpClientErrorException
     */
    @ExceptionHandler(HttpClientErrorException.class)
    public ResponseEntity<ApiResponse<Object>> handleHttpClientErrorException(
            HttpClientErrorException ex) {
        
        log.warn("HTTP client error: {} - {}", ex.getStatusCode(), ex.getMessage());
        
        String message = switch (ex.getStatusCode().value()) {
            case 400 -> "Bad request. Please check your input and try again.";
            case 401 -> "You are not authenticated or session has expired.";
            case 403 -> "You are not authorized to perform this action.";
            case 404 -> "Resource not found.";
            default -> "An error occurred. Please try again later.";
        };
        
        return ResponseEntity.status(ex.getStatusCode())
                .body(ApiResponse.error(message));
    }
    
    /**
     * Xử lý DataAccessException (Database errors)
     */
    @ExceptionHandler(DataAccessException.class)
    public ResponseEntity<ApiResponse<Object>> handleDataAccessException(
            DataAccessException ex) {
        
        log.error("Database error: {}", ex.getMessage(), ex);
        
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error("Database access error. Please try again later."));
    }
    
    /**
     * Xử lý IllegalArgumentException
     */
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ApiResponse<Object>> handleIllegalArgumentException(
            IllegalArgumentException ex) {
        
        log.warn("Illegal argument: {}", ex.getMessage());
        
        return ResponseEntity.badRequest()
                .body(ApiResponse.error(ex.getMessage()));
    }
    
    /**
     * Xử lý lỗi chung (fallback)
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Object>> handleGenericException(Exception ex) {
        
        log.error("Unexpected error: {}", ex.getMessage(), ex);
        
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error("An error occurred in the system. Please try again later."));
    }
}
