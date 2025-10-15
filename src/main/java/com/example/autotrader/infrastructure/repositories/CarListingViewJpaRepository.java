package com.example.autotrader.infrastructure.repositories;

import com.example.autotrader.domain.entities.CarListingView;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.UUID;

/**
 * Spring Data JPA repository for CarListingView
 * 
 * This is the low-level JPA repository that handles:
 * - Database operations on car_listings view
 * - Specification-based dynamic queries
 * - Basic CRUD operations
 * 
 * This repository is used by CarListingViewRepositoryImpl
 * and should not be used directly by use cases.
 */
@Repository
public interface CarListingViewJpaRepository extends 
    JpaRepository<CarListingView, UUID>, 
    JpaSpecificationExecutor<CarListingView> {
    
    // Spring Data JPA automatically provides:
    // - findAll(Specification<CarListingView> spec, Pageable pageable)
    // - findById(UUID id)
    // - count(Specification<CarListingView> spec)
    // - existsById(UUID id)
    // - save() methods (but shouldn't be used for views)
}
