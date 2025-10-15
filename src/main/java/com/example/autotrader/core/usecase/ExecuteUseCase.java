package com.example.autotrader.core.usecase;

import com.example.autotrader.core.data.Either;
import com.example.autotrader.core.data.Failure;
import com.example.autotrader.core.exceptions.BusinessException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataAccessException;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.client.ResourceAccessException;

import java.util.function.Function;
import java.util.function.Supplier;

/**
 * ExecuteUseCase - Unified error handling for use cases in Spring Boot.
 * Inspired by Flutter's ExecuteMixin pattern.
 */
@Slf4j
public class ExecuteUseCase {

    // --- Overload 1: only required params ---
    public static <T> Either<Failure, T> execute(
            Supplier<Either<Failure, T>> func,
            String funcTitle,
            String defaultErrorMessage
    ) {
        return execute(func, funcTitle, defaultErrorMessage, null, null);
    }

    // --- Overload 2: custom BusinessException handler only ---
    public static <T> Either<Failure, T> execute(
            Supplier<Either<Failure, T>> func,
            String funcTitle,
            String defaultErrorMessage,
            Function<BusinessException, Either<Failure, T>> onBusinessException
    ) {
        return execute(func, funcTitle, defaultErrorMessage, onBusinessException, null);
    }

    // --- Overload 3: full version (optional handlers supported) ---
    public static <T> Either<Failure, T> execute(
            Supplier<Either<Failure, T>> func,
            String funcTitle,
            String defaultErrorMessage,
            Function<BusinessException, Either<Failure, T>> onBusinessException,
            Function<Exception, Either<Failure, T>> onOtherException
    ) {
        try {
            return func.get();

        } catch (BusinessException ex) {
            log.warn("Business exception in {}: {} - {}", funcTitle, ex.getErrorCode(), ex.getMessage());

            if (onBusinessException != null) {
                Either<Failure, T> handled = onBusinessException.apply(ex);
                if (handled != null) {
                    return handled;
                }
            }

            return Either.left(Failure.builder()
                    .errorCode(ex.getErrorCode())
                    .message(ex.getMessage())
                    .statusCode(ex.getStatusCode())
                    .details(ex.getDetails())
                    .cause(ex)
                    .build());

        } catch (ResourceAccessException ex) {
            log.error("Network error in {}: {}", funcTitle, ex.getMessage());
            return Either.left(Failure.network("Network connection error. Please try again later."));

        } catch (HttpServerErrorException ex) {
            log.error("Server error in {}: {} - {}", funcTitle, ex.getStatusCode(), ex.getMessage());
            String message = extractServiceErrorMessage(ex);
            return Either.left(Failure.server(message != null ? message : "The system is experiencing issues. Please try again later."));

        } catch (HttpClientErrorException ex) {
            log.warn("Client error in {}: {} - {}", funcTitle, ex.getStatusCode(), ex.getMessage());
            String message = extractServiceErrorMessage(ex);
            if (message == null) {
                message = switch (ex.getStatusCode().value()) {
                    case 400 ->
                        "Bad request. Please check your input and try again.";
                    case 401 ->
                        "You are not authenticated or session has expired.";
                    case 403 ->
                        "You are not authorized to perform this action.";
                    case 404 ->
                        "Resource not found.";
                    default ->
                        defaultErrorMessage;
                };
            }
            return Either.left(Failure.custom(
                    "HTTP_" + ex.getStatusCode().value(),
                    message,
                    ex.getStatusCode().value()
            ));

        } catch (DataAccessException ex) {
            log.error("Database error in {}: {}", funcTitle, ex.getMessage());
            return Either.left(Failure.server("Database access error. Please try again later."));

        } catch (Exception ex) {
            log.error("Unexpected error in {}: {}", funcTitle, ex.getMessage(), ex);

            if (onOtherException != null) {
                Either<Failure, T> handled = onOtherException.apply(ex);
                if (handled != null) {
                    return handled;
                }
            }

            return Either.left(Failure.builder()
                    .errorCode("UNKNOWN_ERROR")
                    .message(defaultErrorMessage)
                    .statusCode(500)
                    .cause(ex)
                    .build());
        }
    }

    /**
     * Extracts error message from HTTP response body
     */
    private static String extractServiceErrorMessage(Exception ex) {
        try {
            String body = null;
            if (ex instanceof HttpClientErrorException clientError) {
                body = clientError.getResponseBodyAsString(); 
            } else if (ex instanceof HttpServerErrorException serverError) {
                body = serverError.getResponseBodyAsString();
            }

            if (body != null) {
                var node = new ObjectMapper().readTree(body);
                if (node.has("message")) {
                    return node.get("message").asText();
                }
            }
        } catch (Exception e) {
            log.debug("Failed to extract service error message", e);
        }
        return null;
    }
}
