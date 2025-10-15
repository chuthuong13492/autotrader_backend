package com.example.autotrader.core.utilities;

import com.example.autotrader.core.data.Either;
import com.example.autotrader.core.data.Failure;
import com.example.autotrader.presentation.dtos.ApiResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

/**
 * Helper utility to convert Either<Failure, T> to ResponseEntity
 * 
 * Makes Controller code much cleaner when using Either pattern
 * 
 * Example usage:
 * <pre>
 * {@code
 * @GetMapping("/{id}")
 * public ResponseEntity<ApiResponse<CarDto>> getCarDetail(@PathVariable UUID id) {
 *     Either<Failure, CarDto> result = useCase.execute(id);
 *     return EitherResponseHelper.toResponse(result, "Get car detail successfully");
 * }
 * }
 * </pre>
 */
public class EitherResponseHelper {
    
    /**
     * Convert Either to ResponseEntity with success message
     * 
     * @param either The Either result from UseCase
     * @param successMessage Message to show on success
     * @param <T> Type of success data
     * @return ResponseEntity with ApiResponse
     */
    public static <T> ResponseEntity<ApiResponse<T>> toResponse(
        Either<Failure, T> either,
        String successMessage
    ) {
        return either.fold(
            // Left case - Failure
            failure -> ResponseEntity
                .status(resolveHttpStatus(failure.getStatusCode()))
                .body(ApiResponse.<T>builder()
                    .success(false)
                    .message(failure.getMessage())
                    .data(null)
                    .timestamp(java.time.LocalDateTime.now().toString())
                    .build()),
            
            // Right case - Success
            data -> ResponseEntity.ok(
                ApiResponse.success(successMessage, data)
            )
        );
    }
    
    /**
     * Convert Either to ResponseEntity without custom success message
     * (Uses default message based on data type)
     */
    public static <T> ResponseEntity<ApiResponse<T>> toResponse(
        Either<Failure, T> either
    ) {
        return toResponse(either, "Operation successful");
    }
    
    /**
     * Convert Either to ResponseEntity with custom status code on success
     * Useful for CREATE operations (201) or NO_CONTENT (204)
     */
    public static <T> ResponseEntity<ApiResponse<T>> toResponse(
        Either<Failure, T> either,
        String successMessage,
        HttpStatus successStatus
    ) {
        return either.fold(
            // Left case - Failure
            failure -> ResponseEntity
                .status(resolveHttpStatus(failure.getStatusCode()))
                .body(ApiResponse.<T>builder()
                    .success(false)
                    .message(failure.getMessage())
                    .data(null)
                    .timestamp(java.time.LocalDateTime.now().toString())
                    .build()),
            
            // Right case - Success with custom status
            data -> ResponseEntity
                .status(successStatus)
                .body(ApiResponse.success(successMessage, data))
        );
    }
    
    /**
     * Handle Either with custom error mapper
     * Useful when you want to customize error response based on failure type
     */
    public static <T> ResponseEntity<ApiResponse<T>> toResponseWithErrorMapper(
        Either<Failure, T> either,
        String successMessage,
        java.util.function.Function<Failure, String> errorMessageMapper
    ) {
        return either.fold(
            // Left case - Failure with custom mapper
            failure -> ResponseEntity
                .status(resolveHttpStatus(failure.getStatusCode()))
                .body(ApiResponse.<T>builder()
                    .success(false)
                    .message(errorMessageMapper.apply(failure))
                    .data(null)
                    .timestamp(java.time.LocalDateTime.now().toString())
                    .build()),
            
            // Right case - Success
            data -> ResponseEntity.ok(
                ApiResponse.success(successMessage, data)
            )
        );
    }
    
    /**
     * Resolve HTTP status from status code
     * Handles both integer codes and HttpStatus enum
     */
    private static HttpStatus resolveHttpStatus(Integer statusCode) {
        if (statusCode == null) {
            return HttpStatus.INTERNAL_SERVER_ERROR;
        }
        
        try {
            return HttpStatus.valueOf(statusCode);
        } catch (IllegalArgumentException e) {
            // If status code is not a standard HTTP status
            return HttpStatus.INTERNAL_SERVER_ERROR;
        }
    }
    
    /**
     * Check if Either is success
     */
    public static <T> boolean isSuccess(Either<Failure, T> either) {
        return either.isRight();
    }
    
    /**
     * Check if Either is failure
     */
    public static <T> boolean isFailure(Either<Failure, T> either) {
        return either.isLeft();
    }
    
    /**
     * Extract data from Either or throw exception
     * Use with caution - only when you're sure it's a success
     */
    public static <T> T getOrThrow(Either<Failure, T> either) {
        return either.fold(
            failure -> {
                throw new RuntimeException(failure.getMessage());
            },
            data -> data
        );
    }
}

