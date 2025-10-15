package com.example.autotrader.infrastructure.repositories;

import com.example.autotrader.domain.entities.CarListingView;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.UUID;

/**
 * Repository for querying car_listings view
 * 
 * This view provides optimized read operations with:
 * - All joins pre-computed
 * - Denormalized data
 * - Single query performance
 * 
 * Use this for:
 * - Search/List operations (GET /api/v1/cars/search)
 * - Display operations
 * 
 * Do NOT use for:
 * - Create/Update/Delete operations (use Car entity instead)
 */
@Repository
public interface CarListingViewRepository extends 
    JpaRepository<CarListingView, UUID>, 
    JpaSpecificationExecutor<CarListingView> {
    
    // Spring Data JPA automatically provides:
    // - findAll(Specification<CarListingView> spec, Pageable pageable)
    // - findById(UUID id)
    // - count(Specification<CarListingView> spec)
}

