package com.example.autotrader.presentation.controllers;

import com.example.autotrader.application.dtos.CarDto;
import com.example.autotrader.application.dtos.CarFilterCriteria;
import com.example.autotrader.application.usecases.GetCarListUseCase;
import com.example.autotrader.core.data.Either;
import com.example.autotrader.core.data.Failure;
import com.example.autotrader.core.data.Pagination;
import com.example.autotrader.core.utilities.EitherResponseHelper;
import com.example.autotrader.presentation.dtos.ApiResponse;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/cars")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class CarController {
    
    private final GetCarListUseCase getCarListUseCase;
    
    /**
     * Tìm kiếm và lọc xe với tất cả các tiêu chí
     * GET /api/v1/cars/search
     * 
     * 
     * Params:
     * - value: Tìm kiếm text (trong make, model, trim)
     * - minPrice: Giá tối thiểu
     * - maxPrice: Giá tối đa
     * - selectedMakes: Tên hãng xe (e.g., "Toyota", "Honda")
     * - selectedModels: Tên dòng xe (e.g., "Camry", "Civic")
     * - selectedTrims: Tên phiên bản (e.g., "LE", "Sport")
     * - selectedBodyTypes: Danh sách tên kiểu dáng, phân tách bằng dấu phẩy (e.g., "SUV,Sedan")
     * - selectedTransmission: Loại hộp số (e.g., "Automatic", "Manual", "All")
     * - sort: relevance|price-asc|price-desc|year-asc|year-desc|mileage-asc|mileage-desc
     * - page: Số trang (bắt đầu từ 1)
     * - size: Số lượng kết quả mỗi trang
     */
    @GetMapping("/search")
    public ResponseEntity<ApiResponse<Pagination<CarDto>>> searchCars(
            @RequestParam(required = false) String value,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(required = false) String selectedMakes,
            @RequestParam(required = false) String selectedModels,
            @RequestParam(required = false) String selectedTrims,
            @RequestParam(required = false) String selectedBodyTypes,
            @RequestParam(required = false) String selectedTransmission,
            @RequestParam(defaultValue = "relevance") String sort,
                    @RequestParam(defaultValue = "1") @Min(1) int page,
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        
        log.info("Searching cars with filters - value: {}, minPrice: {}, maxPrice: {}, makes: {}, models: {}, trims: {}, bodyTypes: {}, transmission: {}, sort: {}, page: {}, size: {}", 
                value, minPrice, maxPrice, selectedMakes, selectedModels, selectedTrims, selectedBodyTypes, selectedTransmission, sort, page, size);
        
        CarFilterCriteria criteria = CarFilterCriteria.builder()
                .value(value)
                .minPrice(minPrice)
                .maxPrice(maxPrice)
                .selectedMake(selectedMakes)         // Name: "Toyota"
                .selectedModel(selectedModels)       // Name: "Camry"
                .selectedTrim(selectedTrims)         // Name: "LE"
                .selectedBodyTypes(parseStringList(selectedBodyTypes))  // Names: ["SUV", "Sedan"]
                .selectedTransmission(selectedTransmission)  // Name: "Automatic"
                .sort(sort)
                .page(page - 1)
                .size(size)
                .build();
        
                // Execute search - returns Either<Failure, Pagination<CarDto>>
                Either<Failure, Pagination<CarDto>> result = getCarListUseCase.execute(criteria);
        
        // Convert Either to ResponseEntity using helper
        return EitherResponseHelper.toResponse(result, "Search cars successfully");
    }
    
    /**
     * Health check endpoint
     * GET /api/v1/cars/health
     */
    @GetMapping("/health")
    public ResponseEntity<ApiResponse<String>> healthCheck() {
        log.info("Health check endpoint called");
        return ResponseEntity.ok(ApiResponse.success("Car service is running", "OK"));
    }
    
    // Helper methods
    
    /**
     * Parse comma-separated string list (for body types)
     * Example: "SUV,Sedan,Hatchback" → ["SUV", "Sedan", "Hatchback"]
     */
    private List<String> parseStringList(String listString) {
        if (listString == null || listString.trim().isEmpty()) {
            return List.of();
        }
        
        return Arrays.stream(listString.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .collect(Collectors.toList());
    }
}
