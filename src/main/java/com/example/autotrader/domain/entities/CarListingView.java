package com.example.autotrader.domain.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.Immutable;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

/**
 * Read-only entity mapping to car_listings database view
 * 
 * This view provides:
 * - All JOINs pre-computed (makes, models, trims, body_types, transmissions, conditions, dealers)
 * - Denormalized data for fast queries
 * - Badges aggregated as JSON
 * - Badge names as array for filtering
 * 
 * Performance benefits:
 * - Single query instead of N+1 queries
 * - No need for lazy loading
 * - Database-level optimization with indexes on view
 */
@Entity
@Table(name = "car_listings")
@Immutable  // Read-only entity - cannot insert/update/delete
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CarListingView {
    
    @Id
    private UUID id;
    
    // Basic info
    private Integer year;
    private Integer mileage;
    private BigDecimal price;
    
    @Column(name = "image_url")
    private String imageUrl;
    
    @Column(name = "is_featured")
    private Boolean isFeatured;
    
    @Column(name = "is_sold")
    private Boolean isSold;
    
    @Column(name = "views_count")
    private Integer viewsCount;
    
    @Column(name = "created_at")
    private OffsetDateTime createdAt;
    
    // Denormalized make/model/trim info (already joined in view)
    @Column(name = "make_name")
    private String makeName;
    
    @Column(name = "model_name")
    private String modelName;
    
    @Column(name = "trim_name")
    private String trimName;
    
    // Denormalized body type info
    @Column(name = "body_type_name")
    private String bodyTypeName;
    
    @Column(name = "body_type_icon")
    private String bodyTypeIcon;
    
    // Denormalized transmission info
    @Column(name = "transmission_type")
    private String transmissionType;
    
    // Denormalized condition info
    @Column(name = "condition_name")
    private String conditionName;
    
    // Denormalized dealer info
    @Column(name = "dealer_name")
    private String dealerName;
    
    @Column(name = "dealer_location")
    private String dealerLocation;
    
    // Badge count for sorting
    @Column(name = "badge_count")
    private Integer badgeCount;
    
    // Badge names as PostgreSQL text array for filtering
    // Example: {"Great Price", "No Accidents"}
    @Column(name = "badge_names", columnDefinition = "text[]")
    private String badgeNamesArray;
    
    // Badges as JSON for display
    // Example: [{"id":"uuid","name":"Great Price","color":"#10B981"}]
    @Column(name = "badges", columnDefinition = "json")
    private String badgesJson;
}

