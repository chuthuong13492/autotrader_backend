package com.example.autotrader.application.dtos;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CarFilterCriteria {
    
    // Search text (searches in make name, model name, trim name)
    private String value;
    
    // Price range
    private BigDecimal minPrice;
    private BigDecimal maxPrice;
    
    // Filter by names (since we use car_listings view with denormalized data)
    private String selectedMake;        // Make name (e.g., "Toyota", "Honda")
    private String selectedModel;       // Model name (e.g., "Camry", "Civic")
    private String selectedTrim;        // Trim name (e.g., "LE", "Sport")
    
    // Body types (list of names, not UUIDs)
    private List<String> selectedBodyTypes;  // e.g., ["SUV", "Sedan"]
    
    // Transmission type name (e.g., "Automatic", "Manual")
    private String selectedTransmission;
    
    // Sort field
    private String sort;
    
    // Pagination
    private Integer page;
    private Integer size;
    
    public enum SortOption {
        RELEVANCE("relevance"),
        PRICE_ASC("price-asc"),
        PRICE_DESC("price-desc"),
        YEAR_ASC("year-asc"),
        YEAR_DESC("year-desc"),
        MILEAGE_ASC("mileage-asc"),
        MILEAGE_DESC("mileage-desc");
        
        private final String value;
        
        SortOption(String value) {
            this.value = value;
        }
        
        public String getValue() {
            return value;
        }
        
        public static SortOption fromValue(String value) {
            for (SortOption option : values()) {
                if (option.value.equals(value)) {
                    return option;
                }
            }
            return RELEVANCE;
        }
    }
}

