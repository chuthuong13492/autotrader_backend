package com.example.autotrader.domain.repositories;

import com.example.autotrader.domain.entities.CarListingView;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.Optional;
import java.util.UUID;

/**
 * Domain repository interface for CarListingView
 * 
 * This repository provides optimized read operations for car listings:
 * - Uses car_listings database view for performance
 * - All JOINs pre-computed at database level
 * - Single query instead of N+1 queries
 * 
 * Use cases:
 * - Search and filtering operations
 * - Pagination and sorting
 * - Display operations
 * 
 * Note: This is a read-only repository for the view.
 * For CUD operations, use CarRepository instead.
 */
public interface CarListingViewRepository {
    
    /**
     * Find all car listings with optional filtering and pagination
     * 
     * @param pageable pagination and sorting information
     * @return Page of car listings
     */
    Page<CarListingView> findAll(Pageable pageable);
    
    /**
     * Find all car listings with specification filtering and pagination
     * 
     * @param spec specification for filtering
     * @param pageable pagination and sorting information
     * @return Page of filtered car listings
     */
    Page<CarListingView> findAll(Specification<CarListingView> spec, Pageable pageable);
    
    /**
     * Find car listing by ID
     * 
     * @param id car listing ID
     * @return Optional car listing
     */
    Optional<CarListingView> findById(UUID id);
    
    /**
     * Count total car listings
     * 
     * @return total count
     */
    long count();
    
    /**
     * Count car listings with specification filtering
     * 
     * @param spec specification for filtering
     * @return count of filtered car listings
     */
    long count(Specification<CarListingView> spec);
    
    /**
     * Check if car listing exists by ID
     * 
     * @param id car listing ID
     * @return true if exists, false otherwise
     */
    boolean existsById(UUID id);
}
