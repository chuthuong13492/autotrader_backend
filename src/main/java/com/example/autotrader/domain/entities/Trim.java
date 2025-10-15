package com.example.autotrader.domain.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "trims", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"model_id", "name"})
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Trim {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "model_id", nullable = false)
    private Model model;
    
    @Column(nullable = false, length = 150)
    private String name;
    
    @Column(name = "engine_type", length = 100)
    private String engineType;
    
    @Column(name = "horsepower")
    private Integer horsepower;
    
    @Column(name = "fuel_economy_city", precision = 4, scale = 1)
    private BigDecimal fuelEconomyCity;
    
    @Column(name = "fuel_economy_highway", precision = 4, scale = 1)
    private BigDecimal fuelEconomyHighway;
    
    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = OffsetDateTime.now();
    }
}

