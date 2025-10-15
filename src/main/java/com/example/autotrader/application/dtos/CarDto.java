package com.example.autotrader.application.dtos;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CarDto {
    // Basic Info
    private UUID id;
    private Integer year;
    private Integer mileage;
    private BigDecimal price;
    private String imageUrl;
    
    // Make info
    private String makeName;
    
    // Model info
    private String modelName;
    
    // Trim info
    private String trimName;
    
    // Body type info
    private String bodyTypeName;
    private String bodyTypeIcon;
    
    // Transmission info
    private String transmissionType;
    
    // Condition info
    private String conditionName;
    
    // Dealer info
    private String dealerName;
    private String dealerLocation;
    
    // Badges
    private List<BadgeDto> badges;
    
    // Metadata
    private Boolean isFeatured;
    private Boolean isSold;
    private Integer viewsCount;
    private OffsetDateTime createdAt;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class BadgeDto {
        private UUID id;
        private String name;
        private String color;
    }
}
