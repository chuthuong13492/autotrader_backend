package com.example.autotrader.presentation.controllers;

import com.example.autotrader.application.dtos.CarDto;
import com.example.autotrader.application.usecases.GetCarDetailUseCase;
import com.example.autotrader.core.data.Either;
import com.example.autotrader.core.data.Failure;
import com.example.autotrader.core.utilities.EitherResponseHelper;
import com.example.autotrader.presentation.dtos.ApiResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

/**
 * Controller using Either pattern for type-safe error handling
 * 
 * Benefits of Either pattern:
 * - Type-safe error handling
 * - Explicit error flow
 * - No hidden exceptions
 * - Functional programming style
 */
@RestController
@RequestMapping("/api/v1/cars")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class CarDetailController {
    
    private final GetCarDetailUseCase getCarDetailUseCase;
    
    /**
     * GET /api/v1/cars/{id}
     * Get car detail by ID with Either pattern
     */
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<CarDto>> getCarDetail(@PathVariable UUID id) {
        log.info("Getting car detail - ID: {}", id);
        
        // Execute use case - returns Either<Failure, CarDto>
        Either<Failure, CarDto> result = getCarDetailUseCase.getCarDetail(id);
        
        // Convert to ResponseEntity using helper (MUCH cleaner!)
        return EitherResponseHelper.toResponse(result, "Get car detail successfully");
    }
}
